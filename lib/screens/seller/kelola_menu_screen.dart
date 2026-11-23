import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/kantin_model.dart';
import '../../models/menu_model.dart';
import '../../services/menu_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/status_colors.dart';
import '../../utils/format.dart';
import '../../utils/menu_validator.dart';
import '../../widgets/category_filter.dart';
import '../../widgets/menu_image.dart';
import '../../widgets/menu_search.dart';
import 'form_menu_screen.dart';

/// Layar Kelola Menu berdiri sendiri (dengan AppBar).
class KelolaMenuScreen extends StatelessWidget {
  const KelolaMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Menu')),
      body: const KelolaMenuView(),
    );
  }
}

/// Isi Kelola Menu tanpa AppBar, supaya bisa dipakai sebagai tab
/// "Kelola Menu" pada bottom navigation SellerHome:
///
///     const KelolaMenuView()
class KelolaMenuView extends StatefulWidget {
  const KelolaMenuView({super.key});

  @override
  State<KelolaMenuView> createState() => _KelolaMenuViewState();
}

class _KelolaMenuViewState extends State<KelolaMenuView> {
  final _service = MenuService();
  late Future<KantinModel?> _kantinFuture = _muat();

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<KantinModel?> _muat() => _service.kantinMilik(_uid);

  void _muatUlang() => setState(() => _kantinFuture = _muat());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<KantinModel?>(
      future: _kantinFuture,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return _Pesan(
            ikon: Icons.cloud_off,
            judul: 'Gagal memuat kantin',
            isi: 'Periksa koneksi internet, lalu coba lagi.',
            tombol: 'Coba Lagi',
            onTombol: _muatUlang,
          );
        }
        final kantin = snap.data;
        if (kantin == null) {
          return _Pesan(
            ikon: Icons.storefront_outlined,
            judul: 'Akun ini belum punya kantin',
            isi: 'Minta pengelola data (Backend) mengisi field ownerUid '
                'pada dokumen kantin dengan UID akun ini:',
            uid: _uid,
            tombol: 'Muat Ulang',
            onTombol: _muatUlang,
          );
        }
        return _DaftarMenu(kantin: kantin, service: _service);
      },
    );
  }
}

class _DaftarMenu extends StatefulWidget {
  final KantinModel kantin;
  final MenuService service;

  const _DaftarMenu({required this.kantin, required this.service});

  @override
  State<_DaftarMenu> createState() => _DaftarMenuState();
}

class _DaftarMenuState extends State<_DaftarMenu> {
  late final Stream<List<MenuModel>> _stream =
      widget.service.streamMenusKantin(widget.kantin.id);
  final _searchController = TextEditingController();
  String _query = '';
  String _kategori = 'Semua';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _pesan(String teks, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(teks),
          backgroundColor: error ? AppStatusColors.danger : null,
        ),
      );
  }

  Future<void> _bukaForm([MenuModel? menu]) async {
    final simpan = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => FormMenuScreen(kantin: widget.kantin, menu: menu),
      ),
    );
    if (simpan == true) {
      _pesan(menu == null ? 'Menu baru ditambahkan' : 'Perubahan disimpan');
    }
  }

  Future<void> _ubahTersedia(MenuModel m, bool nilai) async {
    try {
      await widget.service.ubahTersedia(m.id, nilai);
    } catch (_) {
      _pesan('Gagal mengubah ketersediaan menu', error: true);
    }
  }

  Future<void> _ubahStok(MenuModel m) async {
    final stok = await showDialog<int>(
      context: context,
      builder: (_) => _StokDialog(nama: m.nama, awal: m.stok),
    );
    if (stok == null) return;
    try {
      await widget.service.ubahStok(m.id, stok);
      _pesan('Stok ${m.nama} menjadi $stok');
    } catch (_) {
      _pesan('Gagal mengubah stok', error: true);
    }
  }

  Future<void> _hapus(MenuModel m) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Hapus ${m.nama}?'),
        content: const Text(
          'Menu akan dihapus permanen dan tidak tampil lagi di katalog.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppStatusColors.danger),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (yakin != true) return;
    try {
      await widget.service.hapusMenu(m.id);
      _pesan('${m.nama} dihapus');
    } catch (_) {
      _pesan('Gagal menghapus menu', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _bukaForm(),
        backgroundColor: AppColors.cta,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Menu'),
      ),
      body: StreamBuilder<List<MenuModel>>(
        stream: _stream,
        builder: (context, snap) {
          if (snap.hasError) {
            return const _Pesan(
              ikon: Icons.lock_outline,
              judul: 'Menu tidak bisa dimuat',
              isi: 'Terjadi kesalahan saat membaca data. Pastikan akun ini '
                  'adalah pemilik kantin dan koneksi internet aktif.',
            );
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return _isi(snap.data!);
        },
      ),
    );
  }

  Widget _isi(List<MenuModel> semua) {
    final q = _query.trim().toLowerCase();
    final tampil = semua.where((m) {
      final cocokCari = q.isEmpty || m.nama.toLowerCase().contains(q);
      final cocokKategori = _kategori == 'Semua' || m.kategori == _kategori;
      return cocokCari && cocokKategori;
    }).toList();

    final tersedia = semua.where((m) => m.bisaDipesan).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderKantin(
                kantin: widget.kantin,
                total: semua.length,
                tersedia: tersedia,
              ),
              const SizedBox(height: 14),
              MenuSearch(
                controller: _searchController,
                hintText: 'Cari menu di kantinmu',
                onChanged: (v) => setState(() => _query = v),
              ),
              const SizedBox(height: 12),
              CategoryFilter(
                selectedCategory: _kategori,
                onCategorySelected: (v) => setState(() => _kategori = v),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
        Expanded(
          child: semua.isEmpty
              ? const _Pesan(
                  ikon: Icons.restaurant_menu,
                  judul: 'Belum ada menu',
                  isi: 'Tekan "Tambah Menu" untuk membuat menu pertamamu.',
                )
              : tampil.isEmpty
                  ? const _Pesan(
                      ikon: Icons.search_off,
                      judul: 'Menu tidak ditemukan',
                      isi: 'Coba kata kunci atau kategori lain.',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                      itemCount: tampil.length,
                      itemBuilder: (context, i) {
                        final m = tampil[i];
                        return _MenuRow(
                          menu: m,
                          onToggle: (v) => _ubahTersedia(m, v),
                          onStok: () => _ubahStok(m),
                          onUbah: () => _bukaForm(m),
                          onHapus: () => _hapus(m),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

class _HeaderKantin extends StatelessWidget {
  final KantinModel kantin;
  final int total;
  final int tersedia;

  const _HeaderKantin({
    required this.kantin,
    required this.total,
    required this.tersedia,
  });

  @override
  Widget build(BuildContext context) {
    final habis = total - tersedia;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.storefront, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  kantin.nama,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$total menu · $tersedia tersedia · $habis habis',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final MenuModel menu;
  final ValueChanged<bool> onToggle;
  final VoidCallback onStok;
  final VoidCallback onUbah;
  final VoidCallback onHapus;

  const _MenuRow({
    required this.menu,
    required this.onToggle,
    required this.onStok,
    required this.onUbah,
    required this.onHapus,
  });

  @override
  Widget build(BuildContext context) {
    final m = menu;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: MenuImage(url: m.fotoUrl, iconSize: 30),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.nama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatRupiah(m.harga),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.cta,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _Tag(teks: m.kategori.isEmpty ? '-' : m.kategori),
                        GestureDetector(
                          onTap: onStok,
                          child: _Tag(
                            teks: 'Stok ${m.stok}',
                            ikon: Icons.edit,
                            warna: m.stok == 0
                                ? AppStatusColors.danger
                                : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Switch(value: m.tersedia, onChanged: onToggle),
                  Text(
                    m.tersedia ? 'Tersedia' : 'Habis',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: m.tersedia
                          ? AppStatusColors.success
                          : AppStatusColors.danger,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: onUbah,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Ubah'),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: onHapus,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Hapus'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppStatusColors.danger,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String teks;
  final IconData? ikon;
  final Color warna;

  const _Tag({
    required this.teks,
    this.ikon,
    this.warna = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: warna.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            teks,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: warna,
            ),
          ),
          if (ikon != null) ...[
            const SizedBox(width: 4),
            Icon(ikon, size: 11, color: warna),
          ],
        ],
      ),
    );
  }
}

class _StokDialog extends StatefulWidget {
  final String nama;
  final int awal;

  const _StokDialog({required this.nama, required this.awal});

  @override
  State<_StokDialog> createState() => _StokDialogState();
}

class _StokDialogState extends State<_StokDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: '${widget.awal}');
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _simpan() {
    final error = MenuValidator.stok(_controller.text);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.pop(context, int.parse(_controller.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Stok ${widget.nama}'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: 'Jumlah stok',
          errorText: _error,
        ),
        onSubmitted: (_) => _simpan(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        TextButton(onPressed: _simpan, child: const Text('Simpan')),
      ],
    );
  }
}

/// Pesan tengah layar (kosong / error), dengan tombol opsional.
class _Pesan extends StatelessWidget {
  final IconData ikon;
  final String judul;
  final String isi;
  final String? uid;
  final String? tombol;
  final VoidCallback? onTombol;

  const _Pesan({
    required this.ikon,
    required this.judul,
    required this.isi,
    this.uid,
    this.tombol,
    this.onTombol,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(ikon, size: 72, color: AppColors.accent),
            const SizedBox(height: 12),
            Text(
              judul,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(isi, textAlign: TextAlign.center),
            if (uid != null) ...[
              const SizedBox(height: 10),
              SelectableText(
                uid!.isEmpty ? '(belum login)' : uid!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
            if (tombol != null) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: 220,
                child: ElevatedButton(
                  onPressed: onTombol,
                  child: Text(tombol!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
