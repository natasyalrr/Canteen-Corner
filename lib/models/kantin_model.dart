/// Koleksi `kantins`: nama, lokasi, jamBuka, ownerUid.
class KantinModel {
  final String id;
  final String nama;
  final String lokasi;
  final String jamBuka;
  final String ownerUid;

  const KantinModel({
    required this.id,
    required this.nama,
    this.lokasi = '',
    this.jamBuka = '',
    this.ownerUid = '',
  });

  factory KantinModel.fromMap(Map<String, dynamic> d, String id) {
    return KantinModel(
      id: id,
      nama: (d['nama'] as String?) ?? '',
      lokasi: (d['lokasi'] as String?) ?? '',
      jamBuka: (d['jamBuka'] as String?) ?? '',
      ownerUid: (d['ownerUid'] as String?) ?? '',
    );
  }
}
