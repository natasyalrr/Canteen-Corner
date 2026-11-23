import 'package:flutter/material.dart';

import '../profile/profil_view.dart';
import 'kelola_menu_screen.dart';
import 'seller_orders_screen.dart';

/// Beranda penjual: bottom navigation dengan tiga tab
/// Pesanan Masuk (Anisa), Kelola Menu (Zukhrufa), dan Profil.
/// Tiap layar tab sudah punya Scaffold dan AppBar sendiri.
class SellerHome extends StatefulWidget {
  const SellerHome({super.key});

  @override
  State<SellerHome> createState() => _SellerHomeState();
}

class _SellerHomeState extends State<SellerHome> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack menjaga state tiap tab saat berpindah tab.
      body: IndexedStack(
        index: _index,
        children: [
          const SellerOrdersScreen(),
          const KelolaMenuScreen(),
          Scaffold(
            appBar: AppBar(title: const Text('Profil')),
            body: const ProfilView(),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Pesanan Masuk',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Kelola Menu',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
