import 'package:canteen_corner/utils/menu_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MenuValidator.nama', () {
    test('kosong atau hanya spasi ditolak', () {
      expect(MenuValidator.nama(null), isNotNull);
      expect(MenuValidator.nama(''), 'Nama menu wajib diisi');
      expect(MenuValidator.nama('   '), 'Nama menu wajib diisi');
    });
    test('terlalu pendek atau terlalu panjang ditolak', () {
      expect(MenuValidator.nama('ab'), isNotNull);
      expect(MenuValidator.nama('a' * 41), isNotNull);
    });
    test('nama wajar diterima', () {
      expect(MenuValidator.nama('Es Teh'), isNull);
      expect(MenuValidator.nama('  Nasi Goreng  '), isNull);
      expect(MenuValidator.nama('a' * 40), isNull);
    });
  });

  group('MenuValidator.harga', () {
    test('kosong atau bukan angka ditolak', () {
      expect(MenuValidator.harga(''), 'Harga wajib diisi');
      expect(MenuValidator.harga('abc'), 'Harga harus berupa angka');
      expect(MenuValidator.harga('15.000'), 'Harga harus berupa angka');
    });
    test('di bawah minimum atau di atas maksimum ditolak', () {
      expect(MenuValidator.harga('0'), contains('minimal'));
      expect(MenuValidator.harga('499'), contains('Rp 500'));
      expect(MenuValidator.harga('1000001'), contains('maksimal'));
    });
    test('batas dan harga wajar diterima', () {
      expect(MenuValidator.harga('500'), isNull);
      expect(MenuValidator.harga('15000'), isNull);
      expect(MenuValidator.harga('1000000'), isNull);
    });
  });

  group('MenuValidator.stok', () {
    test('kosong, bukan angka bulat, atau negatif ditolak', () {
      expect(MenuValidator.stok(''), 'Stok wajib diisi');
      expect(MenuValidator.stok('1.5'), 'Stok harus berupa angka bulat');
      expect(MenuValidator.stok('-1'), 'Stok tidak boleh negatif');
    });
    test('melebihi batas ditolak', () {
      expect(MenuValidator.stok('1000'), contains('maksimal'));
    });
    test('0 sampai 999 diterima', () {
      expect(MenuValidator.stok('0'), isNull);
      expect(MenuValidator.stok('25'), isNull);
      expect(MenuValidator.stok('999'), isNull);
    });
  });

  group('MenuValidator.fotoUrl', () {
    test('boleh kosong', () {
      expect(MenuValidator.fotoUrl(null), isNull);
      expect(MenuValidator.fotoUrl(''), isNull);
    });
    test('http, https, dan assets diterima', () {
      expect(MenuValidator.fotoUrl('https://contoh.com/a.jpg'), isNull);
      expect(MenuValidator.fotoUrl('http://contoh.com/a.jpg'), isNull);
      expect(MenuValidator.fotoUrl('assets/images/nasi.jpg'), isNull);
    });
    test('format lain ditolak', () {
      expect(MenuValidator.fotoUrl('contoh.com/a.jpg'), isNotNull);
      expect(MenuValidator.fotoUrl('ftp://contoh.com/a.jpg'), isNotNull);
    });
  });

  test('daftar kategori sama dengan filter katalog', () {
    expect(MenuValidator.kategori, ['Makanan', 'Minuman', 'Snack']);
  });
}
