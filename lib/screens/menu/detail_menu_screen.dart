import 'package:flutter/material.dart';

import '../../models/menu_model.dart';
import '../../theme/app_theme.dart';
import '../../theme/status_colors.dart';
import '../../utils/format.dart';
import '../../widgets/cart_actions.dart';
import '../../widgets/cart_icon_button.dart';
import '../../widgets/menu_image.dart';
import '../../widgets/qty_stepper.dart';
import '../cart/keranjang_screen.dart';

/// Detail satu menu: foto, harga, deskripsi, jumlah, dan catatan.
class DetailMenuScreen extends StatefulWidget {
  final MenuModel menu;
  final String kantinNama;

  const DetailMenuScreen({
    super.key,
    required this.menu,
    required this.kantinNama,
  });

  @override
  State<DetailMenuScreen> createState() => _DetailMenuScreenState();
}

class _DetailMenuScreenState extends State<DetailMenuScreen> {
  final _catatanController = TextEditingController();
  int _qty = 1;

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _tambah() async {
    final ok = await tambahKeKeranjang(
      context,
      widget.menu,
      widget.kantinNama,
      qty: _qty,
      catatan: _catatanController.text.trim(),
    );
    if (!ok || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    navigator.pop();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${widget.menu.nama} ditambahkan ke keranjang'),
          action: SnackBarAction(
            label: 'Lihat',
            onPressed: () => navigator.push(
              MaterialPageRoute(builder: (_) => const KeranjangScreen()),
            ),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final menu = widget.menu;
    final bisa = menu.bisaDipesan;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Menu'),
        actions: const [CartIconButton()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 220,
              width: double.infinity,
              child: MenuImage(url: menu.fotoUrl, iconSize: 64),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  menu.nama,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  menu.kategori,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            formatRupiah(menu.harga),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.cta,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.storefront, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(child: Text(widget.kantinNama)),
              Icon(
                bisa ? Icons.check_circle : Icons.cancel,
                size: 18,
                color: bisa ? AppStatusColors.success : AppStatusColors.danger,
              ),
              const SizedBox(width: 4),
              Text(
                bisa ? 'Tersedia' : 'Habis',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color:
                      bisa ? AppStatusColors.success : AppStatusColors.danger,
                ),
              ),
            ],
          ),
          if (menu.deskripsi.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(menu.deskripsi),
            ),
          ],
          const SizedBox(height: 16),
          const Text(
            'Catatan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _catatanController,
            maxLines: 2,
            maxLength: 100,
            enabled: bisa,
            decoration: const InputDecoration(
              hintText: 'Contoh: tidak pedas, es dipisah',
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Jumlah',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              QtyStepper(
                value: _qty,
                min: 1,
                max: menu.stok < 1 ? 1 : menu.stok,
                onChanged: bisa ? (v) => setState(() => _qty = v) : (_) {},
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Subtotal',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    formatRupiah(menu.harga * _qty),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: bisa ? _tambah : null,
                  icon: const Icon(Icons.add_shopping_cart),
                  label: Text(bisa ? 'Tambah ke Keranjang' : 'Stok Habis'),
                  style: ElevatedButton.styleFrom(
                    disabledBackgroundColor: Colors.grey.shade300,
                    disabledForegroundColor: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
