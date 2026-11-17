/// Koleksi `menus`: kantinId, nama, harga, kategori, stok, fotoUrl, tersedia
/// (+ deskripsi, opsional).
class MenuModel {
  final String id;
  final String kantinId;
  final String nama;
  final int harga;
  final String kategori;
  final int stok;
  final String fotoUrl;
  final bool tersedia;
  final String deskripsi;

  const MenuModel({
    required this.id,
    required this.kantinId,
    required this.nama,
    required this.harga,
    required this.kategori,
    this.stok = 99,
    this.fotoUrl = '',
    this.tersedia = true,
    this.deskripsi = '',
  });

  /// Menu bisa dipesan hanya jika ditandai tersedia dan stok masih ada.
  bool get bisaDipesan => tersedia && stok > 0;

  factory MenuModel.fromMap(Map<String, dynamic> d, String id) {
    return MenuModel(
      id: id,
      kantinId: (d['kantinId'] as String?) ?? '',
      nama: (d['nama'] as String?) ?? '',
      harga: (d['harga'] as num?)?.toInt() ?? 0,
      kategori: (d['kategori'] as String?) ?? '',
      stok: (d['stok'] as num?)?.toInt() ?? 99,
      fotoUrl: (d['fotoUrl'] as String?) ?? '',
      tersedia: (d['tersedia'] as bool?) ?? true,
      deskripsi: (d['deskripsi'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'kantinId': kantinId,
        'nama': nama,
        'harga': harga,
        'kategori': kategori,
        'stok': stok,
        'fotoUrl': fotoUrl,
        'tersedia': tersedia,
        'deskripsi': deskripsi,
      };
}
