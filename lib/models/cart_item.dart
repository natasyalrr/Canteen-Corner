import 'menu_model.dart';

class CartItem {
  final MenuModel menu;
  int qty;
  String catatan;

  CartItem({required this.menu, this.qty = 1, this.catatan = ''});

  int get subtotal => menu.harga * qty;
}
