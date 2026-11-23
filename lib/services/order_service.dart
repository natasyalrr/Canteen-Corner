import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/cart_item.dart';
import '../models/order_model.dart';

/// Sisi mahasiswa untuk koleksi `orders`: membuat pesanan, memantau status,
/// membatalkan, dan menandai kedaluwarsa. Perubahan status oleh penjual
/// (diproses, siap diambil, selesai, konfirmasi tunai) ada di sisi backend.
class OrderService {
  static const durasiTunai = Duration(minutes: 15);

  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('orders');

  /// Membuat pesanan dan mengembalikan id dokumennya.
  /// Pembayaran masih simulasi: metode digital langsung "lunas",
  /// tunai menunggu dibayar di kasir sampai `expiresAt`.
  Future<String> createOrder({
    required List<CartItem> items,
    required String kantinId,
    required String kantinNama,
    required String metodeBayar,
    required String tipePesanan,
    required String jamAmbil,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw StateError('Pengguna belum login');

    final tunai = metodeBayar == PaymentMethod.tunai;
    final now = DateTime.now();
    final total = items.fold<int>(0, (s, i) => s + i.subtotal);
    final ref = _col.doc();

    await ref.set({
      'userId': uid,
      'kantinId': kantinId,
      'kantinNama': kantinNama,
      'items': items.map((i) => OrderItem.fromCart(i).toMap()).toList(),
      'total': total,
      'metodeBayar': metodeBayar,
      'statusBayar': tunai ? PaymentStatus.belumBayar : PaymentStatus.lunas,
      'statusOrder': tunai ? OrderStatus.menungguBayar : OrderStatus.dibayar,
      'kodePesanan': _buatKode(),
      'tipePesanan': tipePesanan,
      'jamAmbil': jamAmbil,
      'expiresAt': tunai ? Timestamp.fromDate(now.add(durasiTunai)) : null,
      'createdAt': Timestamp.fromDate(now),
    });
    return ref.id;
  }

  /// Semua pesanan milik pengguna yang sedang login, terbaru di atas.
  /// Diurutkan di aplikasi supaya tidak butuh composite index Firestore.
  /// Semua pesanan milik pengguna yang sedang login.
  Stream<List<OrderModel>> streamPesananSaya() {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return _col.where('userId', isEqualTo: uid).snapshots().map((s) {
      final list = s.docs
          .map((d) => OrderModel.fromMap(d.data(), d.id))
          .toList();

      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return list;
    });
  } // Penutup streamPesananSaya harus ada di sini!

  /// Mengambil seluruh pesanan yang ditujukan ke kantin penjual.
  Stream<List<OrderModel>> streamPesananMasuk(String kantinId) {
    if (kantinId.isEmpty) {
      throw ArgumentError('kantinId tidak boleh kosong');
    }

    return _col.where('kantinId', isEqualTo: kantinId).snapshots().map((
      snapshot,
    ) {
      final daftarPesanan = snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();

      daftarPesanan.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return daftarPesanan;
    });
  }

  /// Satu pesanan, diperbarui real-time (null jika tidak ditemukan).
  Stream<OrderModel?> streamPesanan(String id) {
    return _col.doc(id).snapshots().map((d) {
      final data = d.data();
      if (!d.exists || data == null) return null;
      return OrderModel.fromMap(data, d.id);
    });
  }

  /// Tandai pesanan tunai yang lewat batas waktu sebagai kedaluwarsa.
  Future<void> tandaiKedaluwarsa(OrderModel o) async {
    if (!o.isExpiredNow) return;
    try {
      await _col.doc(o.id).update({
        'statusBayar': PaymentStatus.kedaluwarsa,
        'statusOrder': OrderStatus.kedaluwarsa,
      });
    } catch (_) {
      // Gagal menulis (offline / aturan Firestore): tampilan tetap
      // menghitung kedaluwarsa dari expiresAt, jadi aman diabaikan.
    }
  }

  Future<void> batalkan(String id) {
    return _col.doc(id).update({'statusOrder': OrderStatus.dibatalkan});
  }

  /// Penjual mengonfirmasi pembayaran tunai.
  /// Jika sudah melewati expiresAt, pesanan ditandai kedaluwarsa.
  Future<void> confirmCashPayment(String orderId) async {
    final ref = _col.doc(orderId);

    final berhasil = await _db.runTransaction<bool>((transaction) async {
      final snapshot = await transaction.get(ref);
      final data = snapshot.data();

      if (!snapshot.exists || data == null) {
        throw StateError('Pesanan tidak ditemukan.');
      }

      if (data['metodeBayar'] != PaymentMethod.tunai) {
        throw StateError('Pesanan ini bukan pembayaran tunai.');
      }

      if (data['statusBayar'] != PaymentStatus.belumBayar ||
          data['statusOrder'] != OrderStatus.menungguBayar) {
        throw StateError('Pesanan tidak sedang menunggu pembayaran.');
      }

      final batasWaktu = data['expiresAt'];

      if (batasWaktu is! Timestamp) {
        throw StateError('Batas waktu pembayaran tidak ditemukan.');
      }

      // Periksa apakah batas waktu pembayaran sudah lewat.
      if (DateTime.now().isAfter(batasWaktu.toDate())) {
        transaction.update(ref, {
          'statusBayar': PaymentStatus.kedaluwarsa,
          'statusOrder': OrderStatus.kedaluwarsa,
        });

        return false;
      }

      // Pembayaran tunai berhasil dikonfirmasi penjual.
      transaction.update(ref, {
        'statusBayar': PaymentStatus.lunas,
        'statusOrder': OrderStatus.dibayar,
      });

      return true;
    });

    if (!berhasil) {
      throw StateError(
        'Pembayaran sudah melewati batas waktu dan pesanan kedaluwarsa.',
      );
    }
  }

  /// Fungsi bantuan untuk mengubah status pesanan oleh penjual.
  /// Hanya pesanan yang memenuhi status sebelumnya yang bisa diubah.
  Future<void> _ubahStatusPenjual({
    required String orderId,
    required List<String> statusDiizinkan,
    required String statusBaru,
    bool wajibLunas = true,
  }) async {
    final ref = _col.doc(orderId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      final data = snapshot.data();

      if (!snapshot.exists || data == null) {
        throw StateError('Pesanan tidak ditemukan.');
      }

      final statusLama = data['statusOrder'];
      final statusBayar = data['statusBayar'];

      // Memastikan perubahan status mengikuti alur pesanan.
      if (!statusDiizinkan.contains(statusLama)) {
        throw StateError('Status pesanan tidak sesuai untuk perubahan ini.');
      }

      // Pesanan harus lunas sebelum mulai diproses.
      if (wajibLunas && statusBayar != PaymentStatus.lunas) {
        throw StateError('Pesanan belum dibayar.');
      }

      transaction.update(ref, {'statusOrder': statusBaru});
    });
  }

  /// Penjual mulai memasak pesanan.
  Future<void> startCooking(String orderId) {
    return _ubahStatusPenjual(
      orderId: orderId,
      statusDiizinkan: [OrderStatus.dibayar],
      statusBaru: OrderStatus.diproses,
    );
  }

  /// Penjual menandai pesanan sudah siap diambil.
  Future<void> markReady(String orderId) {
    return _ubahStatusPenjual(
      orderId: orderId,
      statusDiizinkan: [OrderStatus.diproses],
      statusBaru: OrderStatus.siapDiambil,
    );
  }

  /// Penjual menandai pesanan sudah selesai.
  Future<void> completeOrder(String orderId) {
    return _ubahStatusPenjual(
      orderId: orderId,
      statusDiizinkan: [OrderStatus.siapDiambil],
      statusBaru: OrderStatus.selesai,
    );
  }

  /// Penjual menolak pesanan yang belum diproses.
  Future<void> rejectOrder(String orderId) {
    return _ubahStatusPenjual(
      orderId: orderId,
      statusDiizinkan: [OrderStatus.menungguBayar, OrderStatus.dibayar],
      statusBaru: OrderStatus.dibatalkan,
      wajibLunas: false,
    );
  }

  String _buatKode() => 'CC-${Random().nextInt(9000) + 1000}';
}
