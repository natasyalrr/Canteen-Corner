import 'package:flutter/material.dart';

import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../widgets/status_chip.dart';
import '../menu/menu_screen.dart';
import 'status_pesanan_screen.dart';

/// Tab "Pesanan" di bottom navigation: pesanan aktif + riwayat pesanan.
class RiwayatPesananView extends StatefulWidget {
  const RiwayatPesananView({super.key});

  @override
  State<RiwayatPesananView> createState() => _RiwayatPesananViewState();
}

class _RiwayatPesananViewState extends State<RiwayatPesananView> {
  late final Stream<List<OrderModel>> _stream =
      OrderService().streamPesananSaya();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<OrderModel>>(
      stream: _stream,
      builder: (context, snap) {
        if (snap.hasError) {
          return const Center(child: Text('Gagal memuat riwayat pesanan'));
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final semua = snap.data!;
        if (semua.isEmpty) return const _RiwayatKosong();

        final aktif = semua.where((o) => OrderStatus.aktif(o.statusTampil));
        final lalu = semua.where((o) => !OrderStatus.aktif(o.statusTampil));

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (aktif.isNotEmpty) ...[
              const _Judul('Pesanan Aktif'),
              for (final o in aktif) _OrderCard(order: o),
              const SizedBox(height: 8),
            ],
            if (lalu.isNotEmpty) ...[
              const _Judul('Riwayat Pesanan'),
              for (final o in lalu) _OrderCard(order: o),
            ],
          ],
        );
      },
    );
  }
}

class _Judul extends StatelessWidget {
  final String teks;

  const _Judul(this.teks);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        teks,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _RiwayatKosong extends StatelessWidget {
  const _RiwayatKosong();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long_outlined,
                size: 72, color: AppColors.accent),
            const SizedBox(height: 12),
            const Text(
              'Belum ada pesanan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Text('Pesanan yang kamu buat akan muncul di sini'),
            const SizedBox(height: 20),
            SizedBox(
              width: 220,
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MenuScreen()),
                ),
                child: const Text('Pesan Sekarang'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final o = order;
    final ringkas = o.items.map((i) => '${i.qty}x ${i.nama}').join(', ');

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StatusPesananScreen(orderId: o.id),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  o.kodePesanan,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                StatusChip(status: o.statusTampil),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${o.kantinNama} · ${formatTanggal(o.createdAt)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(ringkas, maxLines: 1, overflow: TextOverflow.ellipsis),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${o.jumlahItem} item',
                    style: const TextStyle(color: Colors.grey)),
                Text(
                  formatRupiah(o.total),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.cta,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
