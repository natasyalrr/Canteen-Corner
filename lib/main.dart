import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/seller/seller_home.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CanteenCorner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const _Memuat();
          }
          final user = snap.data;
          if (user == null) return const LoginScreen();
          return _RoleGate(key: ValueKey(user.uid), user: user);
        },
      ),
    );
  }
}

/// Memilih beranda sesuai peran di `users/{uid}.role`:
/// penjual masuk ke [SellerHome], selain itu ke [HomeScreen].
///
/// Memakai stream (bukan sekali baca) karena saat mendaftar, dokumen
/// `users/{uid}` baru dibuat setelah akun Auth jadi. Selama dokumen belum
/// ada, layar menunggu supaya penjual baru tidak sempat masuk ke beranda
/// mahasiswa.
class _RoleGate extends StatelessWidget {
  final User user;

  const _RoleGate({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snap) {
        // Gagal membaca peran: pakai tampilan mahasiswa (aturan Firestore
        // tetap membatasi aksi penjual).
        if (snap.hasError) return const HomeScreen();

        if (!snap.hasData) return const _Memuat();

        final doc = snap.data!;
        if (!doc.exists) return const _Memuat(tampilkanKeluar: true);

        final role = (doc.data()?['role'] as String?) ?? 'mahasiswa';
        return role == 'penjual' ? const SellerHome() : const HomeScreen();
      },
    );
  }
}

class _Memuat extends StatelessWidget {
  final bool tampilkanKeluar;

  const _Memuat({this.tampilkanKeluar = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (tampilkanKeluar) ...[
              const SizedBox(height: 16),
              const Text('Menyiapkan akun...'),
              TextButton(
                onPressed: () => AuthService().logout(),
                child: const Text('Keluar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
