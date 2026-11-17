import 'package:flutter/material.dart';

/// Warna semantik untuk status (berhasil, gagal, menunggu, selesai).
/// Pelengkap [AppColors] (lihat app_theme.dart); palet utama aplikasi
/// tetap dari AppColors, file ini hanya untuk warna status.
class AppStatusColors {
  /// Tersedia, siap diambil, pembayaran berhasil.
  static const success = Color(0xFF2E7D32);

  /// Habis, dibatalkan, kedaluwarsa, hapus.
  static const danger = Color(0xFFC62828);

  /// Menunggu bayar / hitung mundur (versi gelap AppColors.cta agar terbaca).
  static const warning = Color(0xFFB36B00);

  /// Pesanan selesai.
  static const neutral = Color(0xFF6B7280);
}
