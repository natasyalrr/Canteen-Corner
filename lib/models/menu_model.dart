class MenuModel {
  final String id;
  final String kantinId;
  final String nama;
  final String deskripsi;
  final int harga;
  final String kategori;
  final int stok;
  final String fotoUrl;
  final bool tersedia;

  // Nama kantin untuk ditampilkan di antarmuka.
  // Nilai ini tidak disimpan di dokumen menus.
  final String namaKantin;

  const MenuModel({
    required this.id,
    required this.kantinId,
    required this.nama,
    this.deskripsi = '',
    required this.harga,
    required this.kategori,
    this.stok = 0,
    this.fotoUrl = '',
    this.tersedia = true,
    this.namaKantin = '',
  });

  // Mengubah data Firestore menjadi objek MenuModel.
  factory MenuModel.fromMap(Map<String, dynamic> data, String documentId) {
    return MenuModel(
      id: documentId,
      kantinId: data['kantinId'] ?? '',
      nama: data['nama'] ?? '',
      deskripsi: data['deskripsi'] ?? '',
      harga: (data['harga'] as num?)?.toInt() ?? 0,
      kategori: data['kategori'] ?? '',
      stok: (data['stok'] as num?)?.toInt() ?? 0,
      fotoUrl: data['fotoUrl'] ?? '',
      tersedia: data['tersedia'] ?? true,
    );
  }

  // Mengubah objek MenuModel menjadi Map untuk Firestore.
  Map<String, dynamic> toMap() {
    return {
      'kantinId': kantinId,
      'nama': nama,
      'deskripsi': deskripsi,
      'harga': harga,
      'kategori': kategori,
      'stok': stok,
      'fotoUrl': fotoUrl,
      'tersedia': tersedia,
    };
  }
}
