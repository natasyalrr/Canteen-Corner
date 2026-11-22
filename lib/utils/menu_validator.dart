import 'format.dart';

/// Validasi form menu penjual (dipakai FormMenuScreen, diuji di test/).
/// Setiap fungsi mengembalikan pesan error, atau null jika isian valid.
class MenuValidator {
  static const kategori = ['Makanan', 'Minuman', 'Snack'];
  static const namaMax = 40;
  static const hargaMin = 500;
  static const hargaMax = 1000000;
  static const stokMax = 999;

  static String? nama(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Nama menu wajib diisi';
    if (t.length < 3) return 'Nama menu minimal 3 karakter';
    if (t.length > namaMax) return 'Nama menu maksimal $namaMax karakter';
    return null;
  }

  static String? harga(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Harga wajib diisi';
    final n = int.tryParse(t);
    if (n == null) return 'Harga harus berupa angka';
    if (n < hargaMin) return 'Harga minimal ${formatRupiah(hargaMin)}';
    if (n > hargaMax) return 'Harga maksimal ${formatRupiah(hargaMax)}';
    return null;
  }

  static String? stok(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Stok wajib diisi';
    final n = int.tryParse(t);
    if (n == null) return 'Stok harus berupa angka bulat';
    if (n < 0) return 'Stok tidak boleh negatif';
    if (n > stokMax) return 'Stok maksimal $stokMax';
    return null;
  }

  /// Foto boleh kosong; jika diisi harus tautan http(s) atau aset aplikasi.
  static String? fotoUrl(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return null;
    final ok = t.startsWith('http://') ||
        t.startsWith('https://') ||
        t.startsWith('assets/');
    return ok ? null : 'Gunakan tautan http(s):// atau aset (assets/...)';
  }
}
