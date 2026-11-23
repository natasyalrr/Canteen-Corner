import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/kantin_model.dart';
import '../../services/menu_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/jam_buka.dart';
import '../../widgets/cart_icon_button.dart';
import '../cart/keranjang_screen.dart';
import '../menu/menu_screen.dart';
import '../order/riwayat_pesanan_view.dart';
import '../profile/profil_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;
  int _chipIndex = 0;

  final List<String> _categories = ['Semua', 'Makanan', 'Minuman', 'Snack'];

  // Data kantin dari Firestore (koleksi `kantins`).
  late final Stream<List<KantinModel>> _kantinStream =
      MenuService().streamKantins();

  Widget _sapaan() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Text(
        'Halo!',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      );
    }
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream:
          FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snap) {
        final nama = (snap.data?.data()?['nama'] as String?)?.trim() ?? '';
        return Text(
          nama.isEmpty ? 'Halo!' : 'Halo, $nama',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        );
      },
    );
  }

  Widget _daftarKantin() {
    return StreamBuilder<List<KantinModel>>(
      stream: _kantinStream,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final kantins = snap.data!;
        if (kantins.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: Text('Belum ada kantin yang terdaftar')),
          );
        }
        return Column(children: kantins.map(_buildKantinCard).toList());
      },
    );
  }

  Widget _buildHome() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sapaan(),
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
        _daftarKantin(),
      ],
    );
  }

  Widget _buildKantinCard(KantinModel k) {
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

  Widget _kantinCardBody(KantinModel k) {
    final buka = JamBuka.sedangBuka(k.jamBuka);

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
            decoration: const BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.horizontal(
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
                if (k.lokasi.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(k.lokasi, style: const TextStyle(fontSize: 13)),
                ],
                if (k.jamBuka.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('Buka ${k.jamBuka}'),
                ],
                if (buka != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: buka ? AppColors.cta : Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      buka ? 'Buka' : 'Tutup',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
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
        _ => const ProfilView(),
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
