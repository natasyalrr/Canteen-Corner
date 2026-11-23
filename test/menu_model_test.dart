import 'package:canteen_corner/models/menu_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MenuModel.bisaDipesan', () {
    MenuModel m({required bool tersedia, required int stok}) => MenuModel(
          id: 'm',
          kantinId: 'k',
          nama: 'Tes',
          harga: 10000,
          kategori: 'Makanan',
          tersedia: tersedia,
          stok: stok,
        );

    test('tersedia dan stok ada -> bisa dipesan', () {
      expect(m(tersedia: true, stok: 5).bisaDipesan, isTrue);
    });
    test('stok 0 -> tidak bisa dipesan', () {
      expect(m(tersedia: true, stok: 0).bisaDipesan, isFalse);
    });
    test('ditandai tidak tersedia -> tidak bisa dipesan', () {
      expect(m(tersedia: false, stok: 5).bisaDipesan, isFalse);
    });
  });

  group('MenuModel.fromMap / toMap', () {
    test('membaca semua field', () {
      final menu = MenuModel.fromMap({
        'kantinId': 'k1',
        'nama': 'Nasi Goreng',
        'harga': 15000,
        'kategori': 'Makanan',
        'stok': 20,
        'fotoUrl': 'https://contoh.com/a.jpg',
        'tersedia': false,
        'deskripsi': 'Enak',
      }, 'abc');
      expect(menu.id, 'abc');
      expect(menu.kantinId, 'k1');
      expect(menu.harga, 15000);
      expect(menu.stok, 20);
      expect(menu.tersedia, isFalse);
      expect(menu.deskripsi, 'Enak');
    });

    test('field kosong memakai nilai bawaan', () {
      final menu = MenuModel.fromMap({}, 'x');
      expect(menu.nama, '');
      expect(menu.harga, 0);
      expect(menu.stok, 99);
      expect(menu.tersedia, isTrue);
      expect(menu.fotoUrl, '');
    });

    test('harga bertipe double dari Firestore dibulatkan ke int', () {
      final menu = MenuModel.fromMap({'harga': 15000.0}, 'x');
      expect(menu.harga, 15000);
    });

    test('toMap tidak memuat id dan bisa dibaca kembali', () {
      const asli = MenuModel(
        id: 'jangan-ikut',
        kantinId: 'k1',
        nama: 'Es Teh',
        harga: 5000,
        kategori: 'Minuman',
        stok: 50,
        fotoUrl: '',
        tersedia: true,
        deskripsi: 'Segar',
      );
      final map = asli.toMap();
      expect(map.containsKey('id'), isFalse);
      expect(map.keys.toSet(), {
        'kantinId', 'nama', 'harga', 'kategori',
        'stok', 'fotoUrl', 'tersedia', 'deskripsi',
      });
      final balik = MenuModel.fromMap(map, 'baru');
      expect(balik.nama, 'Es Teh');
      expect(balik.harga, 5000);
      expect(balik.kategori, 'Minuman');
      expect(balik.stok, 50);
    });
  });
}
