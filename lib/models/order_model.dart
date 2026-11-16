class OrderItem {
  final String menuId;
  final String nama;
  final int harga;
  final int jumlah;
  final String catatan;

  const OrderItem({
    required this.menuId,
    required this.nama,
    required this.harga,
    required this.jumlah,
    this.catatan = '',
  });

  // Menghitung subtotal satu jenis menu
  int get subtotal => harga * jumlah;

  // Mengubah data Map menjadi objek OrderItem
  factory OrderItem.fromMap(Map<String, dynamic> data) {
    return OrderItem(
      menuId: data['menuId'] as String? ?? '',
      nama: data['nama'] as String? ?? '',
      harga: (data['harga'] as num?)?.toInt() ?? 0,
      jumlah: (data['jumlah'] as num?)?.toInt() ?? 0,
      catatan: data['catatan'] as String? ?? '',
    );
  }

  // Mengubah objek OrderItem menjadi Map
  Map<String, dynamic> toMap() {
    return {
      'menuId': menuId,
      'nama': nama,
      'harga': harga,
      'jumlah': jumlah,
      'catatan': catatan,
    };
  }
}

class OrderModel {
  // Status pembayaran
  static const String menungguBayar = 'menunggu_bayar';
  static const String dibayar = 'dibayar';
  static const String kedaluwarsa = 'kedaluwarsa';

  // Status pesanan
  static const String menungguDiproses = 'menunggu_diproses';
  static const String diproses = 'diproses';
  static const String siapDiambil = 'siap_diambil';
  static const String selesai = 'selesai';
  static const String dibatalkan = 'dibatalkan';

  // Metode pembayaran
  static const String qris = 'qris';
  static const String eWallet = 'e_wallet';
  static const String transferBank = 'transfer_bank';
  static const String tunai = 'tunai';

  // Tipe pesanan
  static const String makanDiTempat = 'makan_di_tempat';
  static const String dibawaPulang = 'dibawa_pulang';

  // Identitas dan data pesanan
  final String id;
  final String userId;
  final String kantinId;
  final List<OrderItem> items;
  final int total;

  // Informasi transaksi
  final String metodeBayar;
  final String statusBayar;
  final String statusOrder;
  final String kodePesanan;

  // Informasi pengambilan pesanan
  final String tipePesanan;
  final DateTime? jamAmbil;

  // Informasi waktu
  final DateTime? expiresAt;
  final DateTime? createdAt;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.kantinId,
    required this.items,
    required this.total,
    required this.metodeBayar,
    required this.statusBayar,
    required this.statusOrder,
    required this.kodePesanan,
    required this.tipePesanan,
    this.jamAmbil,
    this.expiresAt,
    this.createdAt,
  });

  // Mengubah tanggal dari Firestore menjadi DateTime
  static DateTime? _ubahKeTanggal(dynamic nilai) {
    if (nilai == null) return null;

    if (nilai is DateTime) return nilai;

    if (nilai is String) {
      return DateTime.tryParse(nilai);
    }

    // Mengambil tanggal dari Firestore Timestamp
    try {
      final hasil = nilai.toDate();

      if (hasil is DateTime) {
        return hasil;
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  // Mengubah data dari Firestore menjadi objek OrderModel
  factory OrderModel.fromMap(Map<String, dynamic> data, String documentId) {
    final daftarItem = data['items'] as List<dynamic>? ?? [];

    return OrderModel(
      id: documentId,
      userId: data['userId'] as String? ?? '',
      kantinId: data['kantinId'] as String? ?? '',
      items: daftarItem
          .whereType<Map>()
          .map((item) => OrderItem.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
      total: (data['total'] as num?)?.toInt() ?? 0,
      metodeBayar: data['metodeBayar'] as String? ?? '',
      statusBayar: data['statusBayar'] as String? ?? '',
      statusOrder: data['statusOrder'] as String? ?? '',
      kodePesanan: data['kodePesanan'] as String? ?? '',
      tipePesanan: data['tipePesanan'] as String? ?? '',
      jamAmbil: _ubahKeTanggal(data['jamAmbil']),
      expiresAt: _ubahKeTanggal(data['expiresAt']),
      createdAt: _ubahKeTanggal(data['createdAt']),
    );
  }

  // Mengubah objek OrderModel menjadi Map untuk Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'kantinId': kantinId,
      'items': items.map((item) => item.toMap()).toList(),
      'total': total,
      'metodeBayar': metodeBayar,
      'statusBayar': statusBayar,
      'statusOrder': statusOrder,
      'kodePesanan': kodePesanan,
      'tipePesanan': tipePesanan,
      'jamAmbil': jamAmbil,
      'expiresAt': expiresAt,
      'createdAt': createdAt,
    };
  }
}
