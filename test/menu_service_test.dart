import 'package:canteen_corner/models/menu_model.dart';
import 'package:canteen_corner/services/menu_service.dart';
import 'package:flutter_test/flutter_test.dart';

MenuModel _menu({
  String kantinId = 'kantin-pusat',
  String nama = 'Nasi Goreng',
  int harga = 15000,
  String kategori = 'Makanan',
  int stok = 10,
  bool tersedia = true,
}) {
  return MenuModel(
    id: 'm1',
    kantinId: kantinId,
    nama: nama,
    harga: harga,
    kategori: kategori,
    stok: stok,
    tersedia: tersedia,
  );
}

void main() {
  group('MenuService.pesanKesalahan', () {
    test('menu valid -> null', () {
      expect(MenuService.pesanKesalahan(_menu()), isNull);
    });

    test('kantin kosong ditolak', () {
      expect(MenuService.pesanKesalahan(_menu(kantinId: '')), isNotNull);
    });

    test('nama kosong atau hanya spasi ditolak', () {
      expect(MenuService.pesanKesalahan(_menu(nama: '   ')), isNotNull);
    });

    test('nama lebih dari 100 karakter ditolak', () {
      expect(MenuService.pesanKesalahan(_menu(nama: 'a' * 101)), isNotNull);
    });

    test('harga nol atau negatif ditolak', () {
      expect(MenuService.pesanKesalahan(_menu(harga: 0)), isNotNull);
      expect(MenuService.pesanKesalahan(_menu(harga: -1)), isNotNull);
    });

    test('stok negatif ditolak, stok nol boleh', () {
      expect(MenuService.pesanKesalahan(_menu(stok: -1)), isNotNull);
      expect(MenuService.pesanKesalahan(_menu(stok: 0)), isNull);
    });

    test('kategori di luar daftar ditolak', () {
      expect(MenuService.pesanKesalahan(_menu(kategori: 'Lainnya')), isNotNull);
      for (final k in MenuService.kategoriMenu) {
        expect(MenuService.pesanKesalahan(_menu(kategori: k)), isNull);
      }
    });
  });

  group('MenuModel', () {
    test('toMap lalu fromMap menghasilkan data yang sama', () {
      final asli = _menu();
      final salinan = MenuModel.fromMap(asli.toMap(), asli.id);
      expect(salinan.kantinId, asli.kantinId);
      expect(salinan.nama, asli.nama);
      expect(salinan.harga, asli.harga);
      expect(salinan.kategori, asli.kategori);
      expect(salinan.stok, asli.stok);
      expect(salinan.tersedia, asli.tersedia);
    });

    test('bisaDipesan butuh tersedia dan stok > 0', () {
      expect(_menu().bisaDipesan, isTrue);
      expect(_menu(stok: 0).bisaDipesan, isFalse);
      expect(_menu(tersedia: false).bisaDipesan, isFalse);
    });
  });
}
