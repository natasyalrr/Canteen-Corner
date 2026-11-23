import 'package:canteen_corner/models/menu_model.dart';
import 'package:canteen_corner/services/cart_service.dart';
import 'package:flutter_test/flutter_test.dart';

MenuModel menu(
  String id, {
  String kantinId = 'k1',
  int harga = 10000,
  int stok = 10,
  bool tersedia = true,
}) {
  return MenuModel(
    id: id,
    kantinId: kantinId,
    nama: 'Menu $id',
    harga: harga,
    kategori: 'Makanan',
    stok: stok,
    tersedia: tersedia,
  );
}

void main() {
  final cart = CartService.instance;

  setUp(() => cart.clear());

  test('keranjang awal kosong', () {
    expect(cart.isEmpty, isTrue);
    expect(cart.total, 0);
    expect(cart.totalItem, 0);
    expect(cart.kantinId, isNull);
    expect(cart.kantinNama, isNull);
  });

  test('tambah menu baru', () {
    cart.tambah(menu('a', harga: 15000), kantinNama: 'Kantin Pusat', qty: 2);
    expect(cart.items.length, 1);
    expect(cart.totalItem, 2);
    expect(cart.total, 30000);
    expect(cart.kantinId, 'k1');
    expect(cart.kantinNama, 'Kantin Pusat');
  });

  test('menu yang sama digabung, bukan baris baru', () {
    cart.tambah(menu('a'), kantinNama: 'K');
    cart.tambah(menu('a'), kantinNama: 'K', qty: 2);
    expect(cart.items.length, 1);
    expect(cart.items.single.qty, 3);
  });

  test('jumlah dibatasi oleh stok', () {
    cart.tambah(menu('a', stok: 3), kantinNama: 'K', qty: 5);
    expect(cart.items.single.qty, 3);
    cart.tambah(menu('a', stok: 3), kantinNama: 'K');
    expect(cart.items.single.qty, 3);
  });

  test('total dari beberapa menu', () {
    cart.tambah(menu('a', harga: 15000), kantinNama: 'K', qty: 2);
    cart.tambah(menu('b', harga: 5000), kantinNama: 'K', qty: 3);
    expect(cart.total, 45000);
    expect(cart.totalItem, 5);
  });

  test('satu keranjang hanya untuk satu kantin', () {
    cart.tambah(menu('a', kantinId: 'k1'), kantinNama: 'Kantin 1');
    final lain = menu('b', kantinId: 'k2');
    expect(cart.berbedaKantin(lain), isTrue);
    cart.tambah(lain, kantinNama: 'Kantin 2');
    expect(cart.items.length, 1);
    expect(cart.kantinId, 'k1');
  });

  test('menu habis atau tidak tersedia tidak bisa ditambahkan', () {
    cart.tambah(menu('a', tersedia: false), kantinNama: 'K');
    cart.tambah(menu('b', stok: 0), kantinNama: 'K');
    expect(cart.isEmpty, isTrue);
  });

  test('setQty dibatasi 1 sampai stok', () {
    cart.tambah(menu('a', stok: 4), kantinNama: 'K');
    cart.setQty('a', 3);
    expect(cart.items.single.qty, 3);
    cart.setQty('a', 99);
    expect(cart.items.single.qty, 4);
    cart.setQty('a', 0);
    expect(cart.items.single.qty, 1);
  });

  test('catatan: diganti hanya jika catatan baru tidak kosong', () {
    cart.tambah(menu('a'), kantinNama: 'K', catatan: 'tidak pedas');
    cart.tambah(menu('a'), kantinNama: 'K');
    expect(cart.items.single.catatan, 'tidak pedas');
    cart.setCatatan('a', 'extra sambal');
    expect(cart.items.single.catatan, 'extra sambal');
  });

  test('hapus item terakhir mengosongkan keranjang dan nama kantin', () {
    cart.tambah(menu('a'), kantinNama: 'Kantin Pusat');
    cart.hapus('a');
    expect(cart.isEmpty, isTrue);
    expect(cart.kantinNama, isNull);
  });

  test('clear mengosongkan semuanya', () {
    cart.tambah(menu('a'), kantinNama: 'K');
    cart.tambah(menu('b'), kantinNama: 'K');
    cart.clear();
    expect(cart.isEmpty, isTrue);
    expect(cart.total, 0);
  });

  test('perubahan keranjang memberi tahu listener', () {
    var dipanggil = 0;
    void listener() => dipanggil++;
    cart.addListener(listener);
    cart.tambah(menu('a'), kantinNama: 'K');
    cart.setQty('a', 2);
    cart.hapus('a');
    cart.removeListener(listener);
    expect(dipanggil, 3);
  });
}
