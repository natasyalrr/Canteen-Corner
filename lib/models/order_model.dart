import 'package:cloud_firestore/cloud_firestore.dart';

import 'cart_item.dart';

/// Nilai field `statusOrder`. Dipakai bersama oleh sisi mahasiswa dan penjual.
class OrderStatus {
  static const menungguBayar = 'menunggu_bayar';
  static const dibayar = 'dibayar';
  static const diproses = 'diproses';
  static const siapDiambil = 'siap_diambil';
  static const selesai = 'selesai';
  static const dibatalkan = 'dibatalkan';
  static const kedaluwarsa = 'kedaluwarsa';

  /// Urutan alur normal pesanan.
  static const alur = [menungguBayar, dibayar, diproses, siapDiambil, selesai];

  static String label(String s) {
    switch (s) {
      case menungguBayar:
        return 'Menunggu Bayar';
      case dibayar:
        return 'Dibayar';
      case diproses:
        return 'Diproses';
      case siapDiambil:
        return 'Siap Diambil';
      case selesai:
        return 'Selesai';
      case dibatalkan:
        return 'Dibatalkan';
      case kedaluwarsa:
        return 'Kedaluwarsa';
      default:
        return s;
    }
  }

  static bool aktif(String s) =>
      s == menungguBayar || s == dibayar || s == diproses || s == siapDiambil;
}

/// Nilai field `statusBayar`.
class PaymentStatus {
  static const belumBayar = 'belum_bayar';
  static const lunas = 'lunas';
  static const kedaluwarsa = 'kedaluwarsa';
}

/// Nilai field `metodeBayar`.
class PaymentMethod {
  static const qris = 'qris';
  static const ewallet = 'ewallet';
  static const transfer = 'transfer';
  static const tunai = 'tunai';

  static String label(String m) {
    switch (m) {
      case qris:
        return 'QRIS';
      case ewallet:
        return 'E-Wallet';
      case transfer:
        return 'Transfer Bank';
      case tunai:
        return 'Tunai';
      default:
        return m;
    }
  }
}

/// Nilai field `tipePesanan`.
class TipePesanan {
  static const makanDiTempat = 'makan_di_tempat';
  static const dibawaPulang = 'dibawa_pulang';

  static String label(String t) =>
      t == dibawaPulang ? 'Dibawa pulang' : 'Makan di tempat';
}

class OrderItem {
  final String menuId;
  final String nama;
  final int harga;
  final int qty;
  final String catatan;

  const OrderItem({
    required this.menuId,
    required this.nama,
    required this.harga,
    required this.qty,
    this.catatan = '',
  });

  int get subtotal => harga * qty;

  factory OrderItem.fromCart(CartItem c) => OrderItem(
        menuId: c.menu.id,
        nama: c.menu.nama,
        harga: c.menu.harga,
        qty: c.qty,
        catatan: c.catatan,
      );

  factory OrderItem.fromMap(Map<String, dynamic> d) => OrderItem(
        menuId: (d['menuId'] as String?) ?? '',
        nama: (d['nama'] as String?) ?? '',
        harga: (d['harga'] as num?)?.toInt() ?? 0,
        qty: (d['qty'] as num?)?.toInt() ?? 1,
        catatan: (d['catatan'] as String?) ?? '',
      );

  Map<String, dynamic> toMap() => {
        'menuId': menuId,
        'nama': nama,
        'harga': harga,
        'qty': qty,
        'catatan': catatan,
      };
}

/// Koleksi `orders`.
class OrderModel {
  final String id;
  final String userId;
  final String kantinId;
  final String kantinNama;
  final List<OrderItem> items;
  final int total;
  final String metodeBayar;
  final String statusBayar;
  final String statusOrder;
  final String kodePesanan;
  final String tipePesanan;
  final String jamAmbil;
  final DateTime? expiresAt;
  final DateTime createdAt;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.kantinId,
    required this.kantinNama,
    required this.items,
    required this.total,
    required this.metodeBayar,
    required this.statusBayar,
    required this.statusOrder,
    required this.kodePesanan,
    required this.tipePesanan,
    required this.jamAmbil,
    required this.expiresAt,
    required this.createdAt,
  });

  static DateTime? _ts(dynamic v) => v is Timestamp ? v.toDate() : null;

  factory OrderModel.fromMap(Map<String, dynamic> d, String id) {
    final rawItems = (d['items'] as List?) ?? const [];
    return OrderModel(
      id: id,
      userId: (d['userId'] as String?) ?? '',
      kantinId: (d['kantinId'] as String?) ?? '',
      kantinNama: (d['kantinNama'] as String?) ?? '',
      items: rawItems
          .map((e) => OrderItem.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      total: (d['total'] as num?)?.toInt() ?? 0,
      metodeBayar: (d['metodeBayar'] as String?) ?? PaymentMethod.tunai,
      statusBayar: (d['statusBayar'] as String?) ?? PaymentStatus.belumBayar,
      statusOrder: (d['statusOrder'] as String?) ?? OrderStatus.menungguBayar,
      kodePesanan: (d['kodePesanan'] as String?) ?? '-',
      tipePesanan: (d['tipePesanan'] as String?) ?? TipePesanan.makanDiTempat,
      jamAmbil: (d['jamAmbil'] as String?) ?? 'Secepatnya',
      expiresAt: _ts(d['expiresAt']),
      createdAt: _ts(d['createdAt']) ?? DateTime.now(),
    );
  }

  int get jumlahItem => items.fold<int>(0, (s, i) => s + i.qty);

  /// Pesanan tunai yang masih menunggu dibayar di kasir.
  bool get isMenungguTunai =>
      metodeBayar == PaymentMethod.tunai &&
      statusBayar == PaymentStatus.belumBayar &&
      statusOrder == OrderStatus.menungguBayar;

  /// Batas waktu tunai sudah lewat (diperiksa di aplikasi).
  bool get isExpiredNow =>
      isMenungguTunai &&
      expiresAt != null &&
      DateTime.now().isAfter(expiresAt!);

  /// Status yang ditampilkan ke pengguna (memperhitungkan kedaluwarsa).
  String get statusTampil => isExpiredNow ? OrderStatus.kedaluwarsa : statusOrder;
}
