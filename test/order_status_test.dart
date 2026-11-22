import 'package:canteen_corner/models/order_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

OrderModel buatOrder({
  String metodeBayar = PaymentMethod.tunai,
  String statusBayar = PaymentStatus.belumBayar,
  String statusOrder = OrderStatus.menungguBayar,
  DateTime? expiresAt,
  List<OrderItem> items = const [],
}) {
  return OrderModel(
    id: 'o1',
    userId: 'u1',
    kantinId: 'k1',
    kantinNama: 'Kantin Pusat',
    items: items,
    total: items.fold<int>(0, (s, i) => s + i.subtotal),
    metodeBayar: metodeBayar,
    statusBayar: statusBayar,
    statusOrder: statusOrder,
    kodePesanan: 'CC-1234',
    tipePesanan: TipePesanan.makanDiTempat,
    jamAmbil: 'Secepatnya',
    expiresAt: expiresAt,
    createdAt: DateTime(2026, 11, 22, 10),
  );
}

void main() {
  group('alur status pesanan', () {
    test('urutan alur normal', () {
      expect(OrderStatus.alur, [
        OrderStatus.menungguBayar,
        OrderStatus.dibayar,
        OrderStatus.diproses,
        OrderStatus.siapDiambil,
        OrderStatus.selesai,
      ]);
    });

    test('nilai status sesuai kontrak Firestore', () {
      expect(OrderStatus.menungguBayar, 'menunggu_bayar');
      expect(OrderStatus.siapDiambil, 'siap_diambil');
      expect(OrderStatus.kedaluwarsa, 'kedaluwarsa');
    });

    test('alur penjual: diproses -> siap diambil -> selesai', () {
      final a = OrderStatus.alur;
      expect(a.indexOf(OrderStatus.diproses), lessThan(a.indexOf(OrderStatus.siapDiambil)));
      expect(a.indexOf(OrderStatus.siapDiambil), lessThan(a.indexOf(OrderStatus.selesai)));
    });

    test('label bahasa Indonesia', () {
      expect(OrderStatus.label(OrderStatus.menungguBayar), 'Menunggu Bayar');
      expect(OrderStatus.label(OrderStatus.diproses), 'Diproses');
      expect(OrderStatus.label(OrderStatus.siapDiambil), 'Siap Diambil');
      expect(OrderStatus.label(OrderStatus.dibatalkan), 'Dibatalkan');
      expect(OrderStatus.label('tidak_dikenal'), 'tidak_dikenal');
    });

    test('status aktif vs akhir', () {
      for (final s in [
        OrderStatus.menungguBayar,
        OrderStatus.dibayar,
        OrderStatus.diproses,
        OrderStatus.siapDiambil,
      ]) {
        expect(OrderStatus.aktif(s), isTrue, reason: s);
      }
      for (final s in [
        OrderStatus.selesai,
        OrderStatus.dibatalkan,
        OrderStatus.kedaluwarsa,
      ]) {
        expect(OrderStatus.aktif(s), isFalse, reason: s);
      }
    });

    test('label metode bayar dan tipe pesanan', () {
      expect(PaymentMethod.label(PaymentMethod.qris), 'QRIS');
      expect(PaymentMethod.label(PaymentMethod.ewallet), 'E-Wallet');
      expect(PaymentMethod.label(PaymentMethod.transfer), 'Transfer Bank');
      expect(PaymentMethod.label(PaymentMethod.tunai), 'Tunai');
      expect(TipePesanan.label(TipePesanan.makanDiTempat), 'Makan di tempat');
      expect(TipePesanan.label(TipePesanan.dibawaPulang), 'Dibawa pulang');
    });
  });

  group('kedaluwarsa pembayaran tunai', () {
    test('tunai belum lewat batas: masih menunggu', () {
      final o = buatOrder(
        expiresAt: DateTime.now().add(const Duration(minutes: 10)),
      );
      expect(o.isMenungguTunai, isTrue);
      expect(o.isExpiredNow, isFalse);
      expect(o.statusTampil, OrderStatus.menungguBayar);
    });

    test('tunai lewat batas: tampil kedaluwarsa', () {
      final o = buatOrder(
        expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
      );
      expect(o.isExpiredNow, isTrue);
      expect(o.statusTampil, OrderStatus.kedaluwarsa);
    });

    test('pesanan digital tidak pernah kedaluwarsa', () {
      final o = buatOrder(
        metodeBayar: PaymentMethod.qris,
        statusBayar: PaymentStatus.lunas,
        statusOrder: OrderStatus.dibayar,
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
      );
      expect(o.isMenungguTunai, isFalse);
      expect(o.isExpiredNow, isFalse);
      expect(o.statusTampil, OrderStatus.dibayar);
    });

    test('tunai yang sudah dikonfirmasi penjual tidak kedaluwarsa', () {
      final o = buatOrder(
        statusBayar: PaymentStatus.lunas,
        statusOrder: OrderStatus.dibayar,
        expiresAt: DateTime.now().subtract(const Duration(minutes: 30)),
      );
      expect(o.isMenungguTunai, isFalse);
      expect(o.isExpiredNow, isFalse);
      expect(o.statusTampil, OrderStatus.dibayar);
    });

    test('tanpa expiresAt tidak dianggap kedaluwarsa', () {
      final o = buatOrder(expiresAt: null);
      expect(o.isExpiredNow, isFalse);
    });
  });

  group('OrderModel dan OrderItem', () {
    test('subtotal item dan jumlah item', () {
      final o = buatOrder(items: const [
        OrderItem(menuId: 'm1', nama: 'Nasi Goreng', harga: 15000, qty: 2),
        OrderItem(menuId: 'm2', nama: 'Es Teh', harga: 5000, qty: 3),
      ]);
      expect(o.items.first.subtotal, 30000);
      expect(o.jumlahItem, 5);
      expect(o.total, 45000);
    });

    test('OrderItem toMap lalu fromMap menghasilkan data sama', () {
      const item = OrderItem(
        menuId: 'm1',
        nama: 'Mie Ayam',
        harga: 12000,
        qty: 2,
        catatan: 'tanpa seledri',
      );
      final balik = OrderItem.fromMap(item.toMap());
      expect(balik.menuId, 'm1');
      expect(balik.nama, 'Mie Ayam');
      expect(balik.harga, 12000);
      expect(balik.qty, 2);
      expect(balik.catatan, 'tanpa seledri');
    });

    test('fromMap memakai nilai bawaan jika field kosong', () {
      final o = OrderModel.fromMap({}, 'abc');
      expect(o.id, 'abc');
      expect(o.items, isEmpty);
      expect(o.statusOrder, OrderStatus.menungguBayar);
      expect(o.statusBayar, PaymentStatus.belumBayar);
      expect(o.metodeBayar, PaymentMethod.tunai);
      expect(o.kodePesanan, '-');
      expect(o.expiresAt, isNull);
    });

    test('fromMap membaca Timestamp dan daftar item', () {
      final waktu = DateTime(2026, 11, 22, 10, 30);
      final o = OrderModel.fromMap({
        'userId': 'u1',
        'kantinId': 'k1',
        'kantinNama': 'Kantin Pusat',
        'items': [
          {'menuId': 'm1', 'nama': 'Bakso', 'harga': 14000, 'qty': 1},
        ],
        'total': 14000,
        'metodeBayar': 'qris',
        'statusBayar': 'lunas',
        'statusOrder': 'diproses',
        'kodePesanan': 'CC-4821',
        'createdAt': Timestamp.fromDate(waktu),
        'expiresAt': null,
      }, 'o9');
      expect(o.items.single.nama, 'Bakso');
      expect(o.statusOrder, OrderStatus.diproses);
      expect(o.createdAt, waktu);
      expect(o.expiresAt, isNull);
      expect(o.kodePesanan, 'CC-4821');
    });
  });
}
