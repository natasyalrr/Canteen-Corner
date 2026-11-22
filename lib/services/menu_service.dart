import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/dummy_data.dart';
import '../models/kantin_model.dart';
import '../models/menu_model.dart';

/// Katalog kantin dan menu di Firestore (koleksi `kantins` dan `menus`).
///
/// - Sisi mahasiswa (baca): [streamKantins], [streamMenus]. Boleh memakai
///   data contoh selama koleksi masih kosong.
/// - Sisi penjual (baca/tulis): [streamKantinMilik], [streamMenuKantin],
///   [tambahMenu], [ubahMenu], [hapusMenu], [setTersedia], [ubahStok]
///   (+ nama kompatibilitas [kantinMilik], [streamMenusKantin], [ubahTersedia]).
///   Sengaja TANPA data contoh, supaya penjual tidak mengubah dokumen yang
///   sebenarnya tidak ada di Firestore.
class MenuService {
  /// true  = kalau koleksi masih kosong / gagal dibaca, tampilkan data contoh
  ///         supaya layar tetap bisa didemokan.
  /// false = tampilkan apa adanya dari Firestore. Ubah ke false setelah data
  ///         awal diisi (lihat tool/README.md).
  static const bool pakaiDataContoh = true;

  /// Kategori menu yang dikenali aplikasi. Sama dengan chip kategori di
  /// Beranda dan dengan daftar yang diperiksa di firestore.rules.
  static const kategoriMenu = ['Makanan', 'Minuman', 'Snack'];

  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _kantins =>
      _db.collection('kantins');
  CollectionReference<Map<String, dynamic>> get _menus =>
      _db.collection('menus');

  // ---------------------------------------------------------------------------
  // Mahasiswa: baca katalog
  // ---------------------------------------------------------------------------

  Stream<List<KantinModel>> streamKantins() {
    return _kantins
        .snapshots()
        .map((s) =>
            s.docs.map((d) => KantinModel.fromMap(d.data(), d.id)).toList())
        .transform(_denganContoh<KantinModel>(DummyData.kantins));
  }

  Stream<List<MenuModel>> streamMenus() {
    return _menus
        .snapshots()
        .map((s) =>
            s.docs.map((d) => MenuModel.fromMap(d.data(), d.id)).toList())
        .transform(_denganContoh<MenuModel>(DummyData.menus));
  }

  StreamTransformer<List<T>, List<T>> _denganContoh<T>(List<T> contoh) {
    return StreamTransformer<List<T>, List<T>>.fromHandlers(
      handleData: (data, sink) {
        sink.add(data.isEmpty && pakaiDataContoh ? contoh : data);
      },
      handleError: (error, stack, sink) {
        sink.add(pakaiDataContoh ? contoh : <T>[]);
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Penjual: kelola kantin dan menu miliknya
  // ---------------------------------------------------------------------------

  /// Kantin yang `ownerUid`-nya sama dengan [ownerUid] (uid penjual yang login).
  Stream<List<KantinModel>> streamKantinMilik(String ownerUid) {
    return _kantins.where('ownerUid', isEqualTo: ownerUid).snapshots().map((s) {
      final list =
          s.docs.map((d) => KantinModel.fromMap(d.data(), d.id)).toList();
      list.sort((a, b) => a.nama.compareTo(b.nama));
      return list;
    });
  }

  /// Kantin pertama milik [uid] (null bila belum ada). Dipakai layar Kelola Menu
  /// yang sekarang mengelola satu kantin. Nama sengaja sama dengan extension
  /// di menu_service_penjual.dart (Zukhrufa) supaya berkas itu bisa dihapus.
  Future<KantinModel?> kantinMilik(String uid) async {
    if (uid.isEmpty) return null;
    final s = await _kantins.where('ownerUid', isEqualTo: uid).limit(1).get();
    if (s.docs.isEmpty) return null;
    final d = s.docs.first;
    return KantinModel.fromMap(d.data(), d.id);
  }

  /// Semua menu satu kantin, diurutkan di aplikasi (tanpa composite index).
  Stream<List<MenuModel>> streamMenuKantin(String kantinId) {
    return _menus.where('kantinId', isEqualTo: kantinId).snapshots().map((s) {
      final list =
          s.docs.map((d) => MenuModel.fromMap(d.data(), d.id)).toList();
      list.sort((a, b) => a.nama.compareTo(b.nama));
      return list;
    });
  }

  /// Nama lain [streamMenuKantin], dipakai KelolaMenuScreen (Zukhrufa).
  Stream<List<MenuModel>> streamMenusKantin(String kantinId) =>
      streamMenuKantin(kantinId);

  /// Menambah menu baru dan mengembalikan id dokumennya.
  /// Melempar [ArgumentError] (pesan berbahasa Indonesia) bila data tidak valid.
  Future<String> tambahMenu(MenuModel m) async {
    _pastikanValid(m);
    final ref = _menus.doc();
    await ref.set(_data(m));
    return ref.id;
  }

  /// Mengubah seluruh field menu [MenuModel.id].
  Future<void> ubahMenu(MenuModel m) async {
    _pastikanValid(m);
    await _menus.doc(m.id).update(_data(m));
  }

  Future<void> hapusMenu(String id) => _menus.doc(id).delete();

  /// Menandai menu tersedia / tidak tersedia (tombol di Kelola Menu).
  Future<void> setTersedia(String id, bool tersedia) {
    return _menus.doc(id).update({'tersedia': tersedia});
  }

  /// Nama lain [setTersedia], dipakai KelolaMenuScreen (Zukhrufa).
  Future<void> ubahTersedia(String menuId, bool tersedia) =>
      setTersedia(menuId, tersedia);

  /// Mengubah stok. Stok 0 otomatis menandai menu tidak tersedia.
  Future<void> ubahStok(String id, int stok) {
    final s = stok < 0 ? 0 : stok;
    return _menus.doc(id).update({
      'stok': s,
      if (s == 0) 'tersedia': false,
    });
  }

  // ---------------------------------------------------------------------------
  // Validasi
  // ---------------------------------------------------------------------------

  /// Pesan kesalahan untuk [m], atau null kalau sudah valid. Bisa dipakai
  /// langsung oleh `validator` di form Kelola Menu. Aturannya sama dengan
  /// `validMenu` di firestore.rules.
  static String? pesanKesalahan(MenuModel m) {
    if (m.kantinId.trim().isEmpty) return 'Kantin belum dipilih';
    final nama = m.nama.trim();
    if (nama.isEmpty) return 'Nama menu wajib diisi';
    if (nama.length > 100) return 'Nama menu maksimal 100 karakter';
    if (m.harga <= 0) return 'Harga harus lebih dari 0';
    if (m.stok < 0) return 'Stok tidak boleh negatif';
    if (!kategoriMenu.contains(m.kategori)) return 'Kategori tidak dikenal';
    return null;
  }

  void _pastikanValid(MenuModel m) {
    final pesan = pesanKesalahan(m);
    if (pesan != null) throw ArgumentError(pesan);
  }

  Map<String, dynamic> _data(MenuModel m) =>
      m.toMap()..['nama'] = m.nama.trim();
}
