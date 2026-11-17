import 'package:flutter/material.dart';

import '../../models/kantin_model.dart';
import '../../models/menu_model.dart';
import '../../services/menu_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../widgets/cart_actions.dart';
import '../../widgets/cart_icon_button.dart';
import '../../widgets/category_filter.dart';
import '../../widgets/menu_card.dart';
import '../../widgets/menu_search.dart';
import 'detail_menu_screen.dart';

/// Katalog menu: pencarian, filter kategori, harga, dan kantin.
class MenuScreen extends StatefulWidget {
  /// Dari Beranda: langsung menyaring ke satu kantin.
  final String? initialKantinNama;

  /// Dari kolom cari di Beranda.
  final String initialQuery;

  const MenuScreen({
    super.key,
    this.initialKantinNama,
    this.initialQuery = '',
  });

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  static const _semuaKantin = 'Semua Kantin';
  static const _hargaMax = 50000.0;

  final _service = MenuService();
  late final Stream<List<KantinModel>> _kantinStream = _service.streamKantins();
  late final Stream<List<MenuModel>> _menuStream = _service.streamMenus();

  late final TextEditingController _searchController;
  late String _query;
  late String _kantinFilter;
  String _kategori = 'Semua';
  RangeValues _harga = const RangeValues(0, _hargaMax);

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery;
    _searchController = TextEditingController(text: widget.initialQuery);
    _kantinFilter = widget.initialKantinNama ?? _semuaKantin;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _adaFilterAktif =>
      _kategori != 'Semua' ||
      _kantinFilter != _semuaKantin ||
      _harga.start > 0 ||
      _harga.end < _hargaMax;

  void _resetFilter() {
    setState(() {
      _kategori = 'Semua';
      _kantinFilter = _semuaKantin;
      _harga = const RangeValues(0, _hargaMax);
    });
  }

  List<MenuModel> _saring(List<MenuModel> menus, Map<String, String> namaKantin) {
    final q = _query.trim().toLowerCase();
    return menus.where((m) {
      final kantin = namaKantin[m.kantinId] ?? '';
      final cocokCari = q.isEmpty ||
          m.nama.toLowerCase().contains(q) ||
          kantin.toLowerCase().contains(q);
      final cocokKategori = _kategori == 'Semua' || m.kategori == _kategori;
      final cocokKantin = _kantinFilter == _semuaKantin || kantin == _kantinFilter;
      final cocokHarga = m.harga >= _harga.start &&
          (m.harga <= _harga.end || _harga.end >= _hargaMax);
      return cocokCari && cocokKategori && cocokKantin && cocokHarga;
    }).toList();
  }

  void _filterHarga() {
    var sementara = _harga;
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Filter Harga',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  RangeSlider(
                    values: sementara,
                    min: 0,
                    max: _hargaMax,
                    divisions: 50,
                    activeColor: AppColors.primary,
                    labels: RangeLabels(
                      formatRupiah(sementara.start),
                      formatRupiah(sementara.end),
                    ),
                    onChanged: (v) => setSheet(() => sementara = v),
                  ),
                  Text(
                    '${formatRupiah(sementara.start)} - '
                    '${formatRupiah(sementara.end)}'
                    '${sementara.end >= _hargaMax ? ' atau lebih' : ''}',
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() => _harga = sementara);
                      Navigator.pop(ctx);
                    },
                    child: const Text('Terapkan Filter'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() => _harga = const RangeValues(0, _hargaMax));
                      Navigator.pop(ctx);
                    },
                    child: const Text('Reset Filter'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _filterKantin(List<KantinModel> kantins) {
    final pilihan = [_semuaKantin, ...kantins.map((k) => k.nama)];
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pilih Kantin',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              for (final nama in pilihan)
                ListTile(
                  title: Text(nama),
                  trailing: nama == _kantinFilter
                      ? const Icon(Icons.check_circle, color: AppColors.primary)
                      : null,
                  onTap: () {
                    setState(() => _kantinFilter = nama);
                    Navigator.pop(ctx);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _tambahCepat(MenuModel menu, String kantinNama) async {
    final ok = await tambahKeKeranjang(context, menu, kantinNama);
    if (!ok || !mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('${menu.nama} ditambahkan ke keranjang')),
      );
  }

  void _bukaDetail(MenuModel menu, String kantinNama) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailMenuScreen(menu: menu, kantinNama: kantinNama),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Menu Kantin',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: const [CartIconButton()],
      ),
      body: SafeArea(
        child: StreamBuilder<List<KantinModel>>(
          stream: _kantinStream,
          builder: (context, kantinSnap) {
            final kantins = kantinSnap.data ?? const <KantinModel>[];
            final namaKantin = {for (final k in kantins) k.id: k.nama};

            return StreamBuilder<List<MenuModel>>(
              stream: _menuStream,
              builder: (context, menuSnap) {
                if (!menuSnap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final tampil = _saring(menuSnap.data!, namaKantin);
                return _isi(tampil, kantins, namaKantin);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _isi(
    List<MenuModel> tampil,
    List<KantinModel> kantins,
    Map<String, String> namaKantin,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MenuSearch(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 14),
          CategoryFilter(
            selectedCategory: _kategori,
            onCategorySelected: (v) => setState(() => _kategori = v),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _filterHarga,
                  icon: const Icon(Icons.price_change_outlined, size: 18),
                  label: const Text('Harga'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.accent),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _filterKantin(kantins),
                  icon: const Icon(Icons.storefront_outlined, size: 18),
                  label: Text(
                    _kantinFilter,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.accent),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${tampil.length} menu',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              if (_adaFilterAktif)
                TextButton(
                  onPressed: _resetFilter,
                  child: const Text('Reset filter'),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Expanded(
            child: tampil.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off, size: 60, color: Colors.grey),
                        SizedBox(height: 10),
                        Text(
                          'Menu tidak ditemukan',
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: tampil.length,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 220,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent: 244,
                    ),
                    itemBuilder: (context, i) {
                      final menu = tampil[i];
                      final kantin = namaKantin[menu.kantinId] ?? 'Kantin';
                      return MenuCard(
                        menu: menu,
                        kantinNama: kantin,
                        onTap: () => _bukaDetail(menu, kantin),
                        onAdd: () => _tambahCepat(menu, kantin),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
