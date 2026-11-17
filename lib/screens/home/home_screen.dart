import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/cart_icon_button.dart';
import '../cart/keranjang_screen.dart';
import '../menu/menu_screen.dart';
import '../order/riwayat_pesanan_view.dart';

class Kantin {
  final String nama;
  final String jamBuka;
  final bool buka;

  const Kantin({required this.nama, required this.jamBuka, required this.buka});
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;
  int _chipIndex = 0;

  final List<String> _categories = ['Semua', 'Makanan', 'Minuman', 'Snack'];

  // TODO: ganti dengan data dari Firestore
  final List<Kantin> _kantins = const [
    Kantin(nama: 'Kantin Pusat', jamBuka: '07.00 - 16.00', buka: true),
    Kantin(nama: 'Kantin Fakultas A', jamBuka: '08.00 - 15.00', buka: true),
    Kantin(nama: 'Kantin Fakultas B', jamBuka: '08.00 - 14.00', buka: false),
  ];

  Widget _buildHome() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Halo, Mahasiswa',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const Text('Mau makan apa hari ini?'),
        const SizedBox(height: 16),
        TextField(
          textInputAction: TextInputAction.search,
          onSubmitted: (value) => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MenuScreen(initialQuery: value),
            ),
          ),
          decoration: const InputDecoration(
            hintText: 'Cari kantin atau menu',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              return ChoiceChip(
                label: Text(_categories[i]),
                selected: _chipIndex == i,
                selectedColor: AppColors.secondary,
                labelStyle: TextStyle(
                  color: _chipIndex == i ? Colors.white : Colors.black87,
                ),
                onSelected: (_) => setState(() => _chipIndex = i),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Daftar Kantin',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ..._kantins.map(_buildKantinCard),
      ],
    );
  }

  Widget _buildKantinCard(Kantin k) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MenuScreen(initialKantinNama: k.nama),
        ),
      ),
      child: _kantinCardBody(k),
    );
  }

  Widget _kantinCardBody(Kantin k) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
            ),
            child: const Icon(Icons.storefront, size: 40, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  k.nama,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Buka ${k.jamBuka}'),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: k.buka ? AppColors.cta : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    k.buka ? 'Buka' : 'Tutup',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.chevron_right, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['CanteenCorner', 'Pesanan', 'Keranjang', 'Profil'];

    return Scaffold(
      appBar: AppBar(title: Text(titles[_navIndex])),
      body: switch (_navIndex) {
        0 => _buildHome(),
        1 => const RiwayatPesananView(),
        2 => KeranjangView(
            onLihatMenu: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MenuScreen()),
            ),
          ),
        _ => Center(child: Text('Halaman ${titles[_navIndex]} menyusul')),
      },
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (i) => setState(() => _navIndex = i),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          const NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Pesanan',
          ),
          NavigationDestination(
            icon: const CartBadgeIcon(),
            selectedIcon: const CartBadgeIcon(selected: true),
            label: 'Keranjang',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}