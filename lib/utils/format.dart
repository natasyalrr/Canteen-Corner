/// Format angka menjadi rupiah, contoh: 15000 -> "Rp 15.000".
String formatRupiah(num value) {
  final s = value.round().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    final dariKanan = s.length - i;
    buf.write(s[i]);
    if (dariKanan > 1 && dariKanan % 3 == 1) buf.write('.');
  }
  return 'Rp $buf';
}

const _bulan = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

/// 9:05 -> "09.05"
String formatJam(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}.${t.minute.toString().padLeft(2, '0')}';

/// "17 Nov 2026, 09.05"
String formatTanggal(DateTime t) =>
    '${t.day} ${_bulan[t.month - 1]} ${t.year}, ${formatJam(t)}';

/// Durasi -> "14:32"
String formatSisaWaktu(Duration d) {
  final m = d.inMinutes.toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$m:$s';
}
