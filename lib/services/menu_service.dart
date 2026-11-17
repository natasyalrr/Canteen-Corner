import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/dummy_data.dart';
import '../models/kantin_model.dart';
import '../models/menu_model.dart';

/// Membaca katalog dari Firestore (koleksi `kantins` dan `menus`).
class MenuService {
  /// true  = kalau koleksi masih kosong / gagal dibaca, tampilkan data contoh
  ///         supaya layar tetap bisa didemokan.
  /// false = tampilkan apa adanya dari Firestore. Ubah ke false setelah data
  ///         asli dari backend sudah terisi.
  static const bool pakaiDataContoh = true;

  final _db = FirebaseFirestore.instance;

  Stream<List<KantinModel>> streamKantins() {
    return _db
        .collection('kantins')
        .snapshots()
        .map((s) =>
            s.docs.map((d) => KantinModel.fromMap(d.data(), d.id)).toList())
        .transform(_denganContoh<KantinModel>(DummyData.kantins));
  }

  Stream<List<MenuModel>> streamMenus() {
    return _db
        .collection('menus')
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
}
