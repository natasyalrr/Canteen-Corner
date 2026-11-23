/// Membaca teks jam buka kantin (mis. "07.00 - 16.00") dan menentukan
/// apakah kantin sedang buka.
class JamBuka {
  static final _pola =
      RegExp(r'(\d{1,2})\s*[.:]\s*(\d{2})\s*-\s*(\d{1,2})\s*[.:]\s*(\d{2})');

  /// true = buka, false = tutup, null = format teks tidak dikenali.
  static bool? sedangBuka(String jamBuka, [DateTime? sekarang]) {
    final m = _pola.firstMatch(jamBuka);
    if (m == null) return null;

    final mulai = int.parse(m[1]!) * 60 + int.parse(m[2]!);
    final selesai = int.parse(m[3]!) * 60 + int.parse(m[4]!);
    final now = sekarang ?? DateTime.now();
    final menit = now.hour * 60 + now.minute;

    if (mulai <= selesai) return menit >= mulai && menit < selesai;
    // Jam buka melewati tengah malam, mis. 20.00 - 02.00.
    return menit >= mulai || menit < selesai;
  }
}
