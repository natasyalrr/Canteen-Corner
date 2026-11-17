import 'package:flutter/material.dart';

import '../../models/order_model.dart';
import '../../services/cart_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import 'pembayaran_screen.dart';

/// Checkout: jenis pesanan (makan di tempat / dibawa pulang) dan jam ambil.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const _secepatnya = 'Secepatnya';

  late final List<String> _slotJam = _buatSlotJam();
  String _tipe = TipePesanan.makanDiTempat;
  String _jamAmbil = _secepatnya;

  /// 6 slot jam ambil, setiap 15 menit, mulai ±15 menit dari sekarang.
  List<String> _buatSlotJam() {
    final t = DateTime.now().add(const Duration(minutes: 15));
    final menit = ((t.minute + 14) ~/ 15) * 15;
    final awal = DateTime(t.year, t.month, t.day, t.hour)
        .add(Duration(minutes: menit));
    return [
      for (var i = 0; i < 6; i++) formatJam(awal.add(Duration(minutes: 15 * i))),
    ];
  }

  Widget _judul(String teks) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          teks,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      );

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return ChoiceChip(
      avatar: icon == null
          ? null
          : Icon(icon,
              size: 18, color: selected ? Colors.white : AppColors.primary),
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.secondary,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(
        color: selected ? AppColors.secondary : AppColors.accent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListenableBuilder(
        listenable: CartService.instance,
        builder: (context, _) {
          final cart = CartService.instance;
          if (cart.isEmpty) {
            return const Center(child: Text('Keranjang kosong'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _judul('Pesanan dari ${cart.kantinNama ?? 'kantin'}'),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          for (final item in cart.items)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${item.qty}x',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(item.menu.nama),
                                        if (item.catatan.isNotEmpty)
                                          Text(
                                            'Catatan: ${item.catatan}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Text(formatRupiah(item.subtotal)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _judul('Jenis Pesanan'),
                    Wrap(
                      spacing: 8,
                      children: [
                        _chip(
                          label: TipePesanan.label(TipePesanan.makanDiTempat),
                          icon: Icons.restaurant,
                          selected: _tipe == TipePesanan.makanDiTempat,
                          onTap: () =>
                              setState(() => _tipe = TipePesanan.makanDiTempat),
                        ),
                        _chip(
                          label: TipePesanan.label(TipePesanan.dibawaPulang),
                          icon: Icons.takeout_dining,
                          selected: _tipe == TipePesanan.dibawaPulang,
                          onTap: () =>
                              setState(() => _tipe = TipePesanan.dibawaPulang),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _judul('Jam Ambil'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        for (final jam in [_secepatnya, ..._slotJam])
                          _chip(
                            label: jam,
                            selected: _jamAmbil == jam,
                            onTap: () => setState(() => _jamAmbil = jam),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total pembayaran',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            formatRupiah(cart.total),
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
                            MaterialPageRoute(
                              builder: (_) => PembayaranScreen(
                                tipePesanan: _tipe,
                                jamAmbil: _jamAmbil,
                              ),
                            ),
                          ),
                          child: const Text('Pilih Pembayaran'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
