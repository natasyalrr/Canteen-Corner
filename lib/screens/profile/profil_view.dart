import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/cart_service.dart';
import '../../theme/app_theme.dart';

/// Isi tab "Profil" (mahasiswa) dan tab "Profil" (penjual):
/// data pengguna dari `users/{uid}` dan tombol keluar akun.
/// Tanpa AppBar, supaya bisa dipasang di dalam Scaffold mana pun.
class ProfilView extends StatelessWidget {
  const ProfilView({super.key});

  Future<void> _keluar(BuildContext context) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar akun?'),
        content: const Text('Kamu perlu masuk lagi untuk memakai aplikasi.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (yakin != true || !context.mounted) return;

    Navigator.of(context).popUntil((r) => r.isFirst);
    CartService.instance.clear();
    // Pindah ke layar login otomatis oleh StreamBuilder di main.dart.
    await AuthService().logout();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Kamu belum masuk'));
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snap) {
        if (snap.hasError) {
          return const Center(child: Text('Gagal memuat profil'));
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snap.data!.data() ?? <String, dynamic>{};
        final nama = (data['nama'] as String?)?.trim() ?? '';
        final email = (data['email'] as String?) ?? user.email ?? '-';
        final nim = (data['nim'] as String?)?.trim() ?? '';
        final role = (data['role'] as String?) ?? 'mahasiswa';
        final inisial = nama.isEmpty ? '?' : nama[0].toUpperCase();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 8),
            Center(
              child: CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.primary,
                child: Text(
                  inisial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                nama.isEmpty ? 'Pengguna' : nama,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  role == 'penjual' ? 'Penjual' : 'Mahasiswa',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _Baris(ikon: Icons.email_outlined, label: 'Email', isi: email),
            if (nim.isNotEmpty)
              _Baris(ikon: Icons.badge_outlined, label: 'NIM', isi: nim),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => _keluar(context),
              icon: const Icon(Icons.logout),
              label: const Text('Keluar'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                foregroundColor: Colors.red.shade700,
                side: BorderSide(color: Colors.red.shade700),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Baris extends StatelessWidget {
  final IconData ikon;
  final String label;
  final String isi;

  const _Baris({required this.ikon, required this.label, required this.isi});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(ikon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 2),
                Text(
                  isi,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
