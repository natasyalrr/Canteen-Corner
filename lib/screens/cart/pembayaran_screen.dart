import 'package:flutter/material.dart';

import '../../models/order_model.dart';
import '../../services/cart_service.dart';
import '../../services/order_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/status_colors.dart';
import '../../utils/format.dart';
import '../order/pembayaran_hasil_screen.dart';

class _Metode {
  final String kode;
  final String judul;
  final String keterangan;
  final IconData ikon;

  const _Metode(this.kode, this.judul, this.keterangan, this.ikon);
}

/// Pilih Metode Pembayaran (simulasi) lalu membuat pesanan di Firestore.
class PembayaranScreen extends StatefulWidget {
  final String tipePesanan;
  final String jamAmbil;

  const PembayaranScreen({
    super.key,
    required this.tipePesanan,
    required this.jamAmbil,
  });

  @override
  State<PembayaranScreen> createState() => _PembayaranScreenState();
}

class _PembayaranScreenState extends State<PembayaranScreen> {
  static const _daftar = [
    _Metode(PaymentMethod.qris, 'QRIS',
        'Scan kode QR dengan aplikasi pembayaran apa pun', Icons.qr_code_2),
    _Metode(PaymentMethod.ewallet, 'E-Wallet',
        'GoPay, OVO, DANA, ShopeePay', Icons.account_balance_wallet_outlined),
    _Metode(PaymentMethod.transfer, 'Transfer Bank',
        'Virtual account bank', Icons.account_balance_outlined),
    _Metode(PaymentMethod.tunai, 'Tunai',
        'Bayar di kasir dalam 15 menit', Icons.payments_outlined),
  ];

  final _service = OrderService();
  String _metode = PaymentMethod.qris;
  bool _loading = false;

  Future<void> _bayar() async {
    final cart = CartService.instance;
    if (cart.isEmpty || cart.kantinId == null) return;
    setState(() => _loading = true);

    try {
      // Simulasi proses pembayaran digital.
      if (_metode != PaymentMethod.tunai) {
        await Future.delayed(const Duration(milliseconds: 900));
      }
      final id = await _service.createOrder(
        items: cart.items,
        kantinId: cart.kantinId!,
        kantinNama: cart.kantinNama ?? '',
        metodeBayar: _metode,
        tipePesanan: widget.tipePesanan,
        jamAmbil: widget.jamAmbil,
      );
      cart.clear();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => PembayaranHasilScreen(orderId: id)),
        (route) => route.isFirst,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuat pesanan, coba lagi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = CartService.instance.total;
    final tunai = _metode == PaymentMethod.tunai;
    final batasTunai = DateTime.now().add(OrderService.durasiTunai);

    return Scaffold(
      appBar: AppBar(title: const Text('Metode Pembayaran')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Pilih metode pembayaran',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                for (final m in _daftar) _kartuMetode(m),
                if (tunai)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.cta.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline,
                            color: AppStatusColors.warning),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Bayar di kasir sebelum ${formatJam(batasTunai)}. '
                            'Jika lewat, pesanan otomatis kedaluwarsa.',
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                const Text(
                  'Pembayaran pada tahap ini berupa simulasi.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              top: false,
              child: ElevatedButton(
                onPressed: _loading ? null : _bayar,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(tunai
                        ? 'Buat Pesanan'
                        : 'Bayar ${formatRupiah(total)}'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kartuMetode(_Metode m) {
    final selected = _metode == m.kode;
    return GestureDetector(
      onTap: _loading ? null : () => setState(() => _metode = m.kode),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(m.ikon, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.judul,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    m.keterangan,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: selected ? AppColors.primary : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
