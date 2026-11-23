import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/kantin_model.dart';
import '../models/menu_model.dart';
import 'menu_service.dart';

/// Operasi menu untuk sisi PENJUAL (Kelola Menu).
///
/// Ditulis sebagai extension agar tidak mengubah `menu_service.dart` milik
/// Backend 1 (tidak ada konflik merge). Aturan Dart: kalau `MenuService`
/// nanti punya method dengan nama yang sama, method di class itulah yang
/// dipakai. Setelah method Natasya masuk dan layar sudah dicoba, file ini
/// boleh dihapus.
///
/// Acuan prototipe (useSeller.ts): addNewMenu -> tambahMenu,
/// deleteMenu -> hapusMenu, toggleAvailability -> ubahTersedia,
/// updateStock -> ubahStok.
extension MenuServicePenjual on MenuService {
  CollectionReference<Map<String, dynamic>> get _menus =>
      FirebaseFirestore.instance.collection('menus');

  /// Kantin yang `ownerUid`-nya sama dengan [uid] penjual (null = belum ada).
  Future<KantinModel?> kantinMilik(String uid) async {
    if (uid.isEmpty) return null;
    final s = await FirebaseFirestore.instance
        .collection('kantins')
        .where('ownerUid', isEqualTo: uid)
        .limit(1)
        .get();
    if (s.docs.isEmpty) return null;
    final d = s.docs.first;
    return KantinModel.fromMap(d.data(), d.id);
  }

  /// Menu milik satu kantin (tanpa data contoh), urut abjad.
  Stream<List<MenuModel>> streamMenusKantin(String kantinId) {
    return _menus.where('kantinId', isEqualTo: kantinId).snapshots().map((s) {
      final list =
          s.docs.map((d) => MenuModel.fromMap(d.data(), d.id)).toList();
      list.sort((a, b) => a.nama.toLowerCase().compareTo(b.nama.toLowerCase()));
      return list;
    });
  }

  Future<void> tambahMenu(MenuModel menu) => _menus.add(menu.toMap());

  Future<void> ubahMenu(MenuModel menu) =>
      _menus.doc(menu.id).update(menu.toMap());

  Future<void> ubahTersedia(String menuId, bool tersedia) =>
      _menus.doc(menuId).update({'tersedia': tersedia});

  Future<void> ubahStok(String menuId, int stok) =>
      _menus.doc(menuId).update({'stok': stok});

  Future<void> hapusMenu(String menuId) => _menus.doc(menuId).delete();
}
