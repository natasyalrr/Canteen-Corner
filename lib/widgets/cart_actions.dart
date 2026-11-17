import 'package:flutter/material.dart';

import '../models/menu_model.dart';
import '../services/cart_service.dart';

/// Menambahkan menu ke keranjang. Jika keranjang berisi menu dari kantin lain,
/// tanya dulu apakah keranjang mau dikosongkan. Mengembalikan true bila
/// menu berhasil ditambahkan.
Future<bool> tambahKeKeranjang(
  BuildContext context,
  MenuModel menu,
  String kantinNama, {
  int qty = 1,
  String catatan = '',
}) async {
  final cart = CartService.instance;

  if (cart.berbedaKantin(menu)) {
    final ganti = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ganti kantin?'),
        content: Text(
          'Keranjangmu berisi pesanan dari ${cart.kantinNama ?? 'kantin lain'}. '
          'Satu pesanan hanya bisa dari satu kantin. Kosongkan keranjang dan '
          'tambahkan menu ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ganti'),
          ),
        ],
      ),
    );
    if (ganti != true) return false;
    cart.clear();
  }

  cart.tambah(menu, kantinNama: kantinNama, qty: qty, catatan: catatan);
  return true;
}
