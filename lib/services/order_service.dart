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

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('orders');

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
  Stream<List<OrderModel>> streamPesananSaya() {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return _col.where('userId', isEqualTo: uid).snapshots().map((s) {
      final list =
          s.docs.map((d) => OrderModel.fromMap(d.data(), d.id)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
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

  String _buatKode() => 'CC-${Random().nextInt(9000) + 1000}';
}
