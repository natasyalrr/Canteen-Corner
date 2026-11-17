import 'package:flutter/material.dart';

import '../screens/cart/keranjang_screen.dart';
import '../services/cart_service.dart';
import '../theme/app_theme.dart';

/// Ikon keranjang dengan badge jumlah item (dipakai di bottom nav).
class CartBadgeIcon extends StatelessWidget {
  final bool selected;

  const CartBadgeIcon({super.key, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CartService.instance,
      builder: (context, _) {
        final n = CartService.instance.totalItem;
        return Badge(
          isLabelVisible: n > 0,
          label: Text('$n'),
          backgroundColor: AppColors.cta,
          textColor: Colors.white,
          child: Icon(
            selected ? Icons.shopping_cart : Icons.shopping_cart_outlined,
          ),
        );
      },
    );
  }
}

/// Tombol keranjang untuk AppBar: membuka layar Keranjang.
class CartIconButton extends StatelessWidget {
  const CartIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Keranjang',
      icon: const CartBadgeIcon(),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const KeranjangScreen()),
      ),
    );
  }
}
