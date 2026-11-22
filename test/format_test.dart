import 'package:canteen_corner/utils/format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatRupiah', () {
    test('angka kecil tanpa pemisah', () {
      expect(formatRupiah(0), 'Rp 0');
      expect(formatRupiah(500), 'Rp 500');
      expect(formatRupiah(999), 'Rp 999');
    });

    test('pemisah ribuan dengan titik', () {
      expect(formatRupiah(1000), 'Rp 1.000');
      expect(formatRupiah(5000), 'Rp 5.000');
      expect(formatRupiah(15000), 'Rp 15.000');
      expect(formatRupiah(1250000), 'Rp 1.250.000');
    });

    test('menerima double dan membulatkan', () {
      expect(formatRupiah(15000.0), 'Rp 15.000');
      expect(formatRupiah(14999.6), 'Rp 15.000');
    });
  });

  group('format waktu', () {
    test('formatJam memakai dua digit dan titik', () {
      expect(formatJam(DateTime(2026, 11, 22, 9, 5)), '09.05');
      expect(formatJam(DateTime(2026, 11, 22, 18, 30)), '18.30');
    });

    test('formatTanggal memakai singkatan bulan Indonesia', () {
      expect(formatTanggal(DateTime(2026, 11, 17, 9, 5)), '17 Nov 2026, 09.05');
      expect(formatTanggal(DateTime(2026, 8, 3, 14, 0)), '3 Agu 2026, 14.00');
      expect(formatTanggal(DateTime(2026, 5, 1, 7, 45)), '1 Mei 2026, 07.45');
    });

    test('formatSisaWaktu untuk hitung mundur tunai', () {
      expect(formatSisaWaktu(const Duration(minutes: 15)), '15:00');
      expect(formatSisaWaktu(const Duration(minutes: 14, seconds: 32)), '14:32');
      expect(formatSisaWaktu(const Duration(seconds: 5)), '00:05');
      expect(formatSisaWaktu(Duration.zero), '00:00');
    });
  });
}
