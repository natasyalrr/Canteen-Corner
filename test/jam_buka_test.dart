import 'package:canteen_corner/utils/jam_buka.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JamBuka.sedangBuka', () {
    test('buka di dalam rentang jam', () {
      expect(
        JamBuka.sedangBuka('07.00 - 16.00', DateTime(2026, 11, 23, 10, 30)),
        isTrue,
      );
    });

    test('tutup di luar rentang jam', () {
      expect(
        JamBuka.sedangBuka('07.00 - 16.00', DateTime(2026, 11, 23, 16, 0)),
        isFalse,
      );
      expect(
        JamBuka.sedangBuka('07.00 - 16.00', DateTime(2026, 11, 23, 6, 59)),
        isFalse,
      );
    });

    test('mengenali format dengan titik dua', () {
      expect(
        JamBuka.sedangBuka('08:00-15:00', DateTime(2026, 11, 23, 9, 0)),
        isTrue,
      );
    });

    test('rentang melewati tengah malam', () {
      expect(
        JamBuka.sedangBuka('20.00 - 02.00', DateTime(2026, 11, 23, 23, 0)),
        isTrue,
      );
      expect(
        JamBuka.sedangBuka('20.00 - 02.00', DateTime(2026, 11, 23, 12, 0)),
        isFalse,
      );
    });

    test('format tidak dikenali mengembalikan null', () {
      expect(JamBuka.sedangBuka(''), isNull);
      expect(JamBuka.sedangBuka('sepanjang hari'), isNull);
    });
  });
}
