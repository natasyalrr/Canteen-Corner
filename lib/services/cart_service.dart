import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/menu_model.dart';

/// Keranjang belanja (disimpan di memori selama aplikasi berjalan).
/// Satu keranjang hanya boleh berisi menu dari satu kantin, karena satu
/// dokumen `orders` hanya punya satu `kantinId`.
class CartService extends ChangeNotifier {
  CartService._();
  static final CartService instance = CartService._();

  final List<CartItem> _items = [];
  String? _kantinNama;

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;
  String? get kantinId => _items.isEmpty ? null : _items.first.menu.kantinId;
  String? get kantinNama => _items.isEmpty ? null : _kantinNama;
  int get totalItem => _items.fold<int>(0, (s, i) => s + i.qty);
  int get total => _items.fold<int>(0, (s, i) => s + i.subtotal);

  /// Menu ini berasal dari kantin yang berbeda dengan isi keranjang.
  bool berbedaKantin(MenuModel menu) =>
      _items.isNotEmpty && _items.first.menu.kantinId != menu.kantinId;

  void tambah(
    MenuModel menu, {
    required String kantinNama,
    int qty = 1,
    String catatan = '',
  }) {
    if (!menu.bisaDipesan || berbedaKantin(menu)) return;
    if (_items.isEmpty) _kantinNama = kantinNama;

    final idx = _items.indexWhere((i) => i.menu.id == menu.id);
    if (idx >= 0) {
      final item = _items[idx];
      item.qty = (item.qty + qty).clamp(1, menu.stok).toInt();
      if (catatan.isNotEmpty) item.catatan = catatan;
    } else {
      _items.add(CartItem(
        menu: menu,
        qty: qty.clamp(1, menu.stok).toInt(),
        catatan: catatan,
      ));
    }
    notifyListeners();
  }

  void setQty(String menuId, int qty) {
    final idx = _items.indexWhere((i) => i.menu.id == menuId);
    if (idx < 0) return;
    final item = _items[idx];
    item.qty = qty.clamp(1, item.menu.stok).toInt();
    notifyListeners();
  }

  void setCatatan(String menuId, String catatan) {
    final idx = _items.indexWhere((i) => i.menu.id == menuId);
    if (idx < 0) return;
    _items[idx].catatan = catatan;
    notifyListeners();
  }

  void hapus(String menuId) {
    _items.removeWhere((i) => i.menu.id == menuId);
    if (_items.isEmpty) _kantinNama = null;
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _kantinNama = null;
    notifyListeners();
  }
}
