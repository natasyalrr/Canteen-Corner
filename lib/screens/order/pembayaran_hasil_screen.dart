import 'package:flutter/material.dart';

import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/status_colors.dart';
import '../../utils/format.dart';
import '../../widgets/expiry_countdown.dart';
import 'status_pesanan_screen.dart';

/// Pembayaran Berhasil / Menunggu Pembayaran Tunai / Kedaluwarsa.
class PembayaranHasilScreen extends StatefulWidget {
  final String orderId;

  const PembayaranHasilScreen({super.key, required this.orderId});

  @override
  State<PembayaranHasilScreen> createState() => _PembayaranHasilScreenState();
}

class _PembayaranHasilScreenState extends State<PembayaranHasilScreen> {
  final _service = OrderService();
  late final Stream<OrderModel?> _stream =
      _service.streamPesanan(widget.orderId);


  ({IconData ikon, Color warna, String judul, String isi}) _tampilan(
      OrderModel o) {
    switch (o.statusTampil) {
      case OrderStatus.kedaluwarsa:
        return (
          ikon: Icons.timer_off_outlined,
          warna: AppStatusColors.danger,
          judul: 'Pesanan Kedaluwarsa',
          isi: 'Batas waktu pembayaran tunai sudah habis. '
              'Silakan buat pesanan baru.',
        );
      case OrderStatus.dibatalkan:
        return (
          ikon: Icons.cancel_outlined,
          warna: AppStatusColors.danger,
          judul: 'Pesanan Dibatalkan',
          isi: 'Pesanan ini sudah dibatalkan.',
        );
      case OrderStatus.menungguBayar:
        return (
          ikon: Icons.hourglass_top_rounded,
          warna: AppStatusColors.warning,
          judul: 'Menunggu Pembayaran',
          isi: 'Tunjukkan kode pesanan ke kasir dan bayar sebelum waktu habis.',
        );
      default:
        return (
          ikon: Icons.check_circle_outline,
          warna: AppStatusColors.success,
          judul: 'Pembayaran Berhasil',
          isi: 'Pesananmu sudah diterima kantin dan segera diproses.',
        );
    }
  }

  Widget _baris(String label, String nilai) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Flexible(
            child: Text(
              nilai,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<OrderModel?>(
        stream: _stream,
        builder: (context, snap) {
          if (snap.hasError) {
            return const Center(child: Text('Gagal memuat pesanan'));
          }
          final o = snap.data;
          if (o == null) {
            return snap.connectionState == ConnectionState.waiting
                ? const Center(child: CircularProgressIndicator())
                : const Center(child: Text('Pesanan tidak ditemukan'));
          }

          final t = _tampilan(o);
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 16),
              Icon(t.ikon, size: 96, color: t.warna),
              const SizedBox(height: 12),
              Text(
                t.judul,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: t.warna,
                ),
              ),
              const SizedBox(height: 8),
              Text(t.isi, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              if (o.isMenungguTunai && o.expiresAt != null) ...[
                ExpiryCountdown(
                  expiresAt: o.expiresAt!,
                  onExpired: () {
                    _service.tandaiKedaluwarsa(o);
                    setState(() {});
                  },
                ),
                const SizedBox(height: 16),
              ],
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text('Kode Pesanan',
                        style: TextStyle(color: Colors.grey)),
                    Text(
                      o.kodePesanan,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: AppColors.primary,
                      ),
                    ),
                    const Divider(height: 24),
                    _baris('Kantin', o.kantinNama),
                    _baris('Metode', PaymentMethod.label(o.metodeBayar)),
                    _baris('Jam ambil', o.jamAmbil),
                    _baris('Total', formatRupiah(o.total)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StatusPesananScreen(orderId: o.id),
                  ),
                ),
                child: const Text('Lihat Status Pesanan'),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                child: const Text('Kembali ke Beranda'),
              ),
            ],
          );
        },
      ),
    );
  }
}
