import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/kantin_model.dart';
import '../../models/order_model.dart';
import '../../services/menu_service.dart';
import '../../services/order_service.dart';

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({super.key});

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> {
  static const Color primaryColor = Color(0xFF16697A);
  static const Color accentColor = Color(0xFF489FB5);

  final OrderService _orderService = OrderService();
  final MenuService _menuService = MenuService();

  late Future<KantinModel?> _kantinFuture;

  @override
  void initState() {
    super.initState();
    _kantinFuture = _ambilKantin();
  }

  // Mengambil data kantin milik penjual yang sedang login.
  Future<KantinModel?> _ambilKantin() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      throw StateError('Pengguna belum login.');
    }

    return _menuService.kantinMilik(uid);
  }

  // Menampilkan pesan setelah aksi berhasil atau gagal.
  Future<void> _jalankanAksi(
    Future<void> Function() aksi,
    String pesanSukses,
  ) async {
    try {
      await aksi();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(pesanSukses)));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // Dialog konfirmasi sebelum menolak pesanan.
  Future<void> _konfirmasiTolak(OrderModel pesanan) async {
    final hasil = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tolak Pesanan?'),
          content: Text(
            'Apakah kamu yakin ingin menolak pesanan '
            '${pesanan.kodePesanan}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Kembali'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tolak Pesanan'),
            ),
          ],
        );
      },
    );

    if (hasil == true && mounted) {
      await _jalankanAksi(
        () => _orderService.rejectOrder(pesanan.id),
        'Pesanan berhasil ditolak.',
      );
    }
  }

  // Format harga rupiah.
  String _formatRupiah(int harga) {
    return 'Rp ${harga.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';
  }

  // Format tanggal dan waktu pesanan.
  String _formatTanggal(DateTime tanggal) {
    final hari = tanggal.day.toString().padLeft(2, '0');
    final bulan = tanggal.month.toString().padLeft(2, '0');
    final tahun = tanggal.year;

    final jam = tanggal.hour.toString().padLeft(2, '0');
    final menit = tanggal.minute.toString().padLeft(2, '0');

    return '$hari/$bulan/$tahun, $jam:$menit';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<KantinModel?>(
      future: _kantinFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                'Gagal mengambil data kantin: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final kantin = snapshot.data;

        if (kantin == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Pesanan Masuk')),
            body: const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Akun penjual belum terhubung dengan data kantin.\n\n'
                  'Pastikan koleksi kantins memiliki ownerUid '
                  'yang sesuai dengan UID akun penjual.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        return _buildHalamanPesanan(kantin);
      },
    );
  }

  Widget _buildHalamanPesanan(KantinModel kantin) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFEDE7E3),
        appBar: AppBar(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pesanan Masuk',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Text(kantin.nama, style: const TextStyle(fontSize: 12)),
            ],
          ),
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Perlu Diproses'),
              Tab(text: 'Sedang Dimasak'),
              Tab(text: 'Siap Diambil'),
              Tab(text: 'Selesai'),
            ],
          ),
        ),
        body: StreamBuilder<List<OrderModel>>(
          stream: _orderService.streamPesananMasuk(kantin.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Gagal mengambil pesanan: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              );
            }

            final semuaPesanan = snapshot.data ?? [];

            final perluDiproses = semuaPesanan
                .where(
                  (p) =>
                      p.statusOrder == OrderStatus.menungguBayar ||
                      p.statusOrder == OrderStatus.dibayar,
                )
                .toList();

            final sedangDimasak = semuaPesanan
                .where((p) => p.statusOrder == OrderStatus.diproses)
                .toList();

            final siapDiambil = semuaPesanan
                .where((p) => p.statusOrder == OrderStatus.siapDiambil)
                .toList();

            final selesai = semuaPesanan
                .where((p) => p.statusOrder == OrderStatus.selesai)
                .toList();

            return TabBarView(
              children: [
                _daftarPesanan(perluDiproses, buatAksi: _aksiPerluDiproses),
                _daftarPesanan(sedangDimasak, buatAksi: _aksiSedangDimasak),
                _daftarPesanan(siapDiambil, buatAksi: _aksiSiapDiambil),
                _daftarPesanan(selesai),
              ],
            );
          },
        ),
      ),
    );
  }

  // Menampilkan daftar pesanan dalam setiap tab.
  Widget _daftarPesanan(
    List<OrderModel> daftar, {
    Widget Function(OrderModel)? buatAksi,
  }) {
    if (daftar.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 60, color: Colors.grey),
            SizedBox(height: 12),
            Text('Belum ada pesanan.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: daftar.length,
      separatorBuilder: (_, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final pesanan = daftar[index];

        return _kartuPesanan(pesanan, buatAksi?.call(pesanan));
      },
    );
  }

  // Kartu detail setiap pesanan.
  Widget _kartuPesanan(OrderModel pesanan, Widget? aksi) {
    final status = pesanan.isExpiredNow
        ? OrderStatus.kedaluwarsa
        : pesanan.statusOrder;

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  pesanan.kodePesanan,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: primaryColor,
                  ),
                ),
                Text(
                  OrderStatus.label(status),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              'Waktu pesan: ${_formatTanggal(pesanan.createdAt)}',
              style: const TextStyle(fontSize: 12),
            ),

            const Divider(height: 20),

            ...pesanan.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.nama} x${item.qty}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text(_formatRupiah(item.subtotal)),
                      ],
                    ),
                    if (item.catatan.isNotEmpty)
                      Text(
                        'Catatan: ${item.catatan}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const Divider(height: 20),

            Text(
              'Total: ${_formatRupiah(pesanan.total)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: primaryColor,
              ),
            ),

            const SizedBox(height: 8),

            Text('Pembayaran: ${PaymentMethod.label(pesanan.metodeBayar)}'),

            Text('Status bayar: ${pesanan.statusBayar}'),

            Text('Tipe pesanan: ${TipePesanan.label(pesanan.tipePesanan)}'),

            Text('Jam ambil: ${pesanan.jamAmbil}'),

            if (aksi != null) ...[const SizedBox(height: 16), aksi],
          ],
        ),
      ),
    );
  }

  // Tombol untuk tab Perlu Diproses.
  Widget _aksiPerluDiproses(OrderModel pesanan) {
    if (pesanan.isExpiredNow) {
      return const Text(
        'Waktu pembayaran sudah berakhir.',
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      );
    }

    if (pesanan.isMenungguTunai) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ElevatedButton.icon(
            onPressed: () => _jalankanAksi(
              () => _orderService.confirmCashPayment(pesanan.id),
              'Pembayaran tunai berhasil dikonfirmasi.',
            ),
            icon: const Icon(Icons.payments),
            label: const Text('Konfirmasi Tunai'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
          OutlinedButton(
            onPressed: () => _konfirmasiTolak(pesanan),
            child: const Text('Tolak Pesanan'),
          ),
        ],
      );
    }

    if (pesanan.statusOrder == OrderStatus.dibayar) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ElevatedButton.icon(
            onPressed: () => _jalankanAksi(
              () => _orderService.startCooking(pesanan.id),
              'Pesanan mulai diproses.',
            ),
            icon: const Icon(Icons.restaurant),
            label: const Text('Mulai Proses'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
          OutlinedButton(
            onPressed: () => _konfirmasiTolak(pesanan),
            child: const Text('Tolak Pesanan'),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  // Tombol untuk tab Sedang Dimasak.
  Widget _aksiSedangDimasak(OrderModel pesanan) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _jalankanAksi(
          () => _orderService.markReady(pesanan.id),
          'Pesanan siap diambil.',
        ),
        icon: const Icon(Icons.check_circle_outline),
        label: const Text('Tandai Siap Diambil'),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  // Tombol untuk tab Siap Diambil.
  Widget _aksiSiapDiambil(OrderModel pesanan) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _jalankanAksi(
          () => _orderService.completeOrder(pesanan.id),
          'Pesanan telah selesai.',
        ),
        icon: const Icon(Icons.done_all),
        label: const Text('Tandai Selesai'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
