// Tes widget komponen UI yang dipakai bersama (tanpa Firebase).
import 'package:canteen_corner/models/order_model.dart';
import 'package:canteen_corner/theme/app_theme.dart';
import 'package:canteen_corner/widgets/qty_stepper.dart';
import 'package:canteen_corner/widgets/status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget bungkus(Widget child) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('StatusChip', () {
    testWidgets('menampilkan label status dalam bahasa Indonesia',
        (tester) async {
      for (final s in OrderStatus.alur) {
        await tester.pumpWidget(bungkus(StatusChip(status: s)));
        expect(find.text(OrderStatus.label(s)), findsOneWidget, reason: s);
      }
    });

    testWidgets('status gagal tampil dengan label masing-masing',
        (tester) async {
      await tester.pumpWidget(
          bungkus(const StatusChip(status: OrderStatus.kedaluwarsa)));
      expect(find.text('Kedaluwarsa'), findsOneWidget);

      await tester.pumpWidget(
          bungkus(const StatusChip(status: OrderStatus.dibatalkan)));
      expect(find.text('Dibatalkan'), findsOneWidget);
    });

    test('status gagal berwarna sama dan berbeda dari status siap diambil', () {
      expect(StatusChip.warna(OrderStatus.kedaluwarsa),
          StatusChip.warna(OrderStatus.dibatalkan));
      expect(StatusChip.warna(OrderStatus.siapDiambil),
          isNot(StatusChip.warna(OrderStatus.dibatalkan)));
    });
  });

  group('QtyStepper', () {
    Widget stepper(ValueNotifier<int> nilai, {int min = 1, int max = 3}) {
      return bungkus(ValueListenableBuilder<int>(
        valueListenable: nilai,
        builder: (context, v, _) => QtyStepper(
          value: v,
          min: min,
          max: max,
          onChanged: (x) => nilai.value = x,
        ),
      ));
    }

    testWidgets('tombol + dan - mengubah jumlah', (tester) async {
      final nilai = ValueNotifier<int>(1);
      await tester.pumpWidget(stepper(nilai));
      expect(find.text('1'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(nilai.value, 2);
      expect(find.text('2'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();
      expect(nilai.value, 1);
    });

    testWidgets('tidak turun di bawah minimum', (tester) async {
      final nilai = ValueNotifier<int>(1);
      await tester.pumpWidget(stepper(nilai));
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();
      expect(nilai.value, 1);
    });

    testWidgets('tidak naik di atas maksimum (stok)', (tester) async {
      final nilai = ValueNotifier<int>(3);
      await tester.pumpWidget(stepper(nilai));
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(nilai.value, 3);
    });
  });
}
