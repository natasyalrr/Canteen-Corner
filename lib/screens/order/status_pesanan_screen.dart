import 'package:flutter/material.dart';

import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/status_colors.dart';
import '../../utils/format.dart';
import '../../widgets/expiry_countdown.dart';
import '../../widgets/status_chip.dart';

/// Status Antrean: kode pesanan, tahapan pesanan real-time, dan rincian.
class StatusPesananScreen extends StatefulWidget {
  final String orderId;

  const StatusPesananScreen({super.key, required this.orderId});

  @override
  State<StatusPesananScreen> createState() => _StatusPesananScreenState();
}

class _StatusPesananScreenState extends State<StatusPesananScreen> {
  final _service = OrderService();
  late final Stream<OrderModel?> _stream =
      _service.streamPesanan(widget.orderId);

  Future<void> _batalkan() async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan pesanan?'),
        content: const Text('Pesanan yang dibatalkan tidak bisa dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, batalkan'),
          ),
        ],
      ),
    );
    if (yakin == true) await _service.batalkan(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Status Pesanan')),
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
          return _isi(o);
        },
      ),
    );
  }

  Widget _isi(OrderModel o) {
    final status = o.statusTampil;
    final gagal =
        status == OrderStatus.kedaluwarsa || status == OrderStatus.dibatalkan;
    final bisaBatal = o.isMenungguTunai && !o.isExpiredNow;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _KodeCard(order: o, status: status),
        const SizedBox(height: 16),
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
        if (gagal)
          _BannerGagal(status: status)
        else
          _Timeline(current: o.statusOrder),
        const SizedBox(height: 16),
        _DetailCard(order: o),
        if (bisaBatal) ...[
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: _batalkan,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppStatusColors.danger,
              side: const BorderSide(color: AppStatusColors.danger),
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Batalkan Pesanan'),
          ),
        ],
      ],
    );
  }
}

class _KodeCard extends StatelessWidget {
  final OrderModel order;
  final String status;

  const _KodeCard({required this.order, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text('Nomor Antrean',
              style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 4),
          Text(
            order.kodePesanan,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: StatusChip(status: status),
          ),
        ],
      ),
    );
  }
}

class _BannerGagal extends StatelessWidget {
  final String status;

  const _BannerGagal({required this.status});

  @override
  Widget build(BuildContext context) {
    final kedaluwarsa = status == OrderStatus.kedaluwarsa;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppStatusColors.danger.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            kedaluwarsa ? Icons.timer_off_outlined : Icons.cancel_outlined,
            color: AppStatusColors.danger,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              kedaluwarsa
                  ? 'Pesanan kedaluwarsa karena tidak dibayar sebelum batas waktu.'
                  : 'Pesanan ini sudah dibatalkan.',
            ),
          ),
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  final String current;

  const _Timeline({required this.current});

  @override
  Widget build(BuildContext context) {
    final idx = OrderStatus.alur.indexOf(current);
    final langkah = OrderStatus.alur;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Perkembangan Pesanan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < langkah.length; i++) ...[
            Row(
              children: [
                Icon(
                  i <= idx ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: i <= idx ? AppColors.primary : Colors.grey.shade400,
                ),
                const SizedBox(width: 12),
                Text(
                  OrderStatus.label(langkah[i]),
                  style: TextStyle(
                    fontWeight: i == idx ? FontWeight.bold : FontWeight.normal,
                    color: i <= idx ? Colors.black87 : Colors.grey,
                  ),
                ),
              ],
            ),
            if (i < langkah.length - 1)
              Container(
                width: 2,
                height: 18,
                margin: const EdgeInsets.only(left: 11),
                color: i < idx ? AppColors.primary : Colors.grey.shade300,
              ),
          ],
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final OrderModel order;

  const _DetailCard({required this.order});

  Widget _baris(String label, String nilai) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(width: 16),
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
    final o = order;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rincian Pesanan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _baris('Kantin', o.kantinNama),
          _baris('Jenis pesanan', TipePesanan.label(o.tipePesanan)),
          _baris('Jam ambil', o.jamAmbil),
          _baris('Metode bayar', PaymentMethod.label(o.metodeBayar)),
          _baris('Waktu pesan', formatTanggal(o.createdAt)),
          const Divider(height: 24),
          for (final item in o.items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${item.qty}x',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.nama),
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
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                formatRupiah(o.total),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
