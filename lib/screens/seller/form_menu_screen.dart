import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/kantin_model.dart';
import '../../models/menu_model.dart';
import '../../services/menu_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/status_colors.dart';
import '../../utils/menu_validator.dart';
import '../../widgets/menu_image.dart';

/// Form tambah menu baru, atau ubah menu jika [menu] diisi.
/// Mengembalikan `true` lewat Navigator.pop saat berhasil disimpan.
class FormMenuScreen extends StatefulWidget {
  final KantinModel kantin;
  final MenuModel? menu;

  const FormMenuScreen({super.key, required this.kantin, this.menu});

  @override
  State<FormMenuScreen> createState() => _FormMenuScreenState();
}

class _FormMenuScreenState extends State<FormMenuScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = MenuService();

  late final _nama = TextEditingController(text: widget.menu?.nama ?? '');
  late final _harga = TextEditingController(
    text: widget.menu == null ? '' : '${widget.menu!.harga}',
  );
  late final _stok =
      TextEditingController(text: '${widget.menu?.stok ?? 10}');
  late final _deskripsi =
      TextEditingController(text: widget.menu?.deskripsi ?? '');
  late final _foto = TextEditingController(text: widget.menu?.fotoUrl ?? '');

  late String _kategori = _kategoriAwal();
  late bool _tersedia = widget.menu?.tersedia ?? true;
  late String _pratinjau = _foto.text.trim();
  bool _menyimpan = false;

  bool get _modeUbah => widget.menu != null;

  String _kategoriAwal() {
    final k = widget.menu?.kategori ?? '';
    return MenuValidator.kategori.contains(k) ? k : MenuValidator.kategori.first;
  }

  @override
  void dispose() {
    _nama.dispose();
    _harga.dispose();
    _stok.dispose();
    _deskripsi.dispose();
    _foto.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() => _menyimpan = true);

    final menu = MenuModel(
      id: widget.menu?.id ?? '',
      kantinId: widget.kantin.id,
      nama: _nama.text.trim(),
      harga: int.parse(_harga.text.trim()),
      kategori: _kategori,
      stok: int.parse(_stok.text.trim()),
      fotoUrl: _foto.text.trim(),
      tersedia: _tersedia,
      deskripsi: _deskripsi.text.trim(),
    );

    try {
      if (_modeUbah) {
        await _service.ubahMenu(menu);
      } else {
        await _service.tambahMenu(menu);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _menyimpan = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menyimpan menu, coba lagi'),
          backgroundColor: AppStatusColors.danger,
        ),
      );
    }
  }

  Widget _label(String teks) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          teks,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_modeUbah ? 'Ubah Menu' : 'Tambah Menu')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Kantin: ${widget.kantin.nama}',
              style: const TextStyle(color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            _label('Nama menu'),
            TextFormField(
              controller: _nama,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              maxLength: MenuValidator.namaMax,
              decoration: const InputDecoration(hintText: 'Contoh: Nasi Goreng'),
              validator: MenuValidator.nama,
            ),
            const SizedBox(height: 8),
            _label('Kategori'),
            Wrap(
              spacing: 8,
              children: [
                for (final k in MenuValidator.kategori)
                  ChoiceChip(
                    label: Text(k),
                    selected: _kategori == k,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _kategori = k),
                    selectedColor: AppColors.secondary,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: _kategori == k ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide(
                      color:
                          _kategori == k ? AppColors.secondary : AppColors.accent,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Harga'),
                      TextFormField(
                        controller: _harga,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          prefixText: 'Rp ',
                          hintText: '15000',
                        ),
                        validator: MenuValidator.harga,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Stok'),
                      TextFormField(
                        controller: _stok,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: MenuValidator.stok,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _label('Deskripsi (opsional)'),
            TextFormField(
              controller: _deskripsi,
              maxLines: 3,
              maxLength: 150,
              decoration: const InputDecoration(
                hintText: 'Contoh: Nasi goreng dengan telur dan sayuran',
              ),
            ),
            const SizedBox(height: 8),
            _label('Foto (opsional)'),
            TextFormField(
              controller: _foto,
              keyboardType: TextInputType.url,
              onEditingComplete: () {
                FocusScope.of(context).unfocus();
                setState(() => _pratinjau = _foto.text.trim());
              },
              onTapOutside: (_) {
                FocusScope.of(context).unfocus();
                setState(() => _pratinjau = _foto.text.trim());
              },
              decoration: const InputDecoration(
                hintText: 'https://... atau assets/images/menu.jpg',
              ),
              validator: MenuValidator.fotoUrl,
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 150,
                width: double.infinity,
                child: MenuImage(url: _pratinjau, iconSize: 48),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SwitchListTile(
                title: const Text('Tersedia untuk dipesan'),
                subtitle: Text(
                  _tersedia
                      ? 'Menu tampil dan bisa dipesan mahasiswa'
                      : 'Menu tampil sebagai "Habis"',
                ),
                value: _tersedia,
                onChanged: (v) => setState(() => _tersedia = v),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _menyimpan ? null : _simpan,
            child: _menyimpan
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(_modeUbah ? 'Simpan Perubahan' : 'Simpan Menu'),
          ),
        ),
      ),
    );
  }
}
