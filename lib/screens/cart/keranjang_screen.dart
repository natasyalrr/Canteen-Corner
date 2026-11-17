import 'package:flutter/material.dart';

import '../../models/cart_item.dart';
import '../../services/cart_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/status_colors.dart';
import '../../utils/format.dart';
import '../../widgets/menu_image.dart';
import '../../widgets/qty_stepper.dart';
import 'checkout_screen.dart';

/// Layar Keranjang berdiri sendiri (dibuka dari ikon keranjang / snackbar).
class KeranjangScreen extends StatelessWidget {
  const KeranjangScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang')),
      // Keranjang kosong -> kembali ke layar menu yang membukanya.
      body: KeranjangView(onLihatMenu: () => Navigator.pop(context)),
    );
  }
}

/// Isi keranjang tanpa Scaffold, supaya bisa dipakai juga sebagai tab
/// "Keranjang" di bottom navigation Beranda.
class KeranjangView extends StatelessWidget {
  /// Dipanggil oleh tombol "Lihat Menu" saat keranjang kosong. Diisi oleh
  /// pemanggil, supaya layar ini tidak perlu mengimpor MenuScreen
  /// (menghindari import melingkar).
  final VoidCallback? onLihatMenu;

  const KeranjangView({super.key, this.onLihatMenu});

  Future<void> _konfirmasiKosongkan(BuildContext context) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kosongkan keranjang?'),
        content: const Text('Semua menu di keranjang akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Kosongkan'),
          ),
        ],
      ),
    );
    if (yakin == true) CartService.instance.clear();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CartService.instance,
      builder: (context, _) {
        final cart = CartService.instance;
        if (cart.isEmpty) return _KeranjangKosong(onLihatMenu: onLihatMenu);

        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      const Icon(Icons.storefront, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          cart.kantinNama ?? 'Kantin',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _konfirmasiKosongkan(context),
                        child: const Text('Kosongkan'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  for (final item in cart.items) _CartItemCard(item: item),
                ],
              ),
            ),
            _RingkasanBar(total: cart.total, jumlah: cart.totalItem),
          ],
        );
      },
    );
  }
}

class _KeranjangKosong extends StatelessWidget {
  final VoidCallback? onLihatMenu;

  const _KeranjangKosong({this.onLihatMenu});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shopping_cart_outlined,
                size: 72, color: AppColors.accent),
            const SizedBox(height: 12),
            const Text(
              'Keranjang masih kosong',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Text('Yuk pilih menu favoritmu dulu'),
            if (onLihatMenu != null) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: 220,
                child: ElevatedButton(
                  onPressed: onLihatMenu,
                  child: const Text('Lihat Menu'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;

  const _CartItemCard({required this.item});

  Future<void> _editCatatan(BuildContext context) async {
    final hasil = await showDialog<String>(
      context: context,
      builder: (_) => _CatatanDialog(awal: item.catatan),
    );
    if (hasil != null) CartService.instance.setCatatan(item.menu.id, hasil);
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartService.instance;
    final adaCatatan = item.catatan.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 72,
              height: 72,
              child: MenuImage(url: item.menu.fotoUrl, iconSize: 30),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.menu.nama,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatRupiah(item.menu.harga),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.cta,
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => _editCatatan(context),
                  child: Row(
                    children: [
                      const Icon(Icons.edit_note,
                          size: 18, color: AppColors.secondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          adaCatatan ? item.catatan : 'Tambah catatan',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: adaCatatan
                                ? Colors.black87
                                : AppColors.secondary,
                            fontStyle:
                                adaCatatan ? FontStyle.italic : FontStyle.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              IconButton(
                tooltip: 'Hapus',
                onPressed: () => cart.hapus(item.menu.id),
                icon: const Icon(Icons.delete_outline),
                color: AppStatusColors.danger,
                visualDensity: VisualDensity.compact,
              ),
              QtyStepper(
                value: item.qty,
                min: 1,
                max: item.menu.stok < 1 ? 1 : item.menu.stok,
                onChanged: (v) => cart.setQty(item.menu.id, v),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CatatanDialog extends StatefulWidget {
  final String awal;

  const _CatatanDialog({required this.awal});

  @override
  State<_CatatanDialog> createState() => _CatatanDialogState();
}

class _CatatanDialogState extends State<_CatatanDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.awal);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Catatan untuk penjual'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: 2,
        maxLength: 100,
        decoration: const InputDecoration(
          hintText: 'Contoh: tidak pedas, es dipisah',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}

class _RingkasanBar extends StatelessWidget {
  final int total;
  final int jumlah;

  const _RingkasanBar({required this.total, required this.jumlah});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total ($jumlah item)',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  formatRupiah(total),
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
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                ),
                child: const Text('Checkout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
