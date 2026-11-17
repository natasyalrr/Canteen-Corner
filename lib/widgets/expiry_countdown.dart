import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/status_colors.dart';
import '../utils/format.dart';

/// Hitung mundur batas bayar tunai. Memanggil [onExpired] sekali saat habis.
class ExpiryCountdown extends StatefulWidget {
  final DateTime expiresAt;
  final VoidCallback? onExpired;

  const ExpiryCountdown({super.key, required this.expiresAt, this.onExpired});

  @override
  State<ExpiryCountdown> createState() => _ExpiryCountdownState();
}

class _ExpiryCountdownState extends State<ExpiryCountdown> {
  Timer? _timer;
  Duration _sisa = Duration.zero;
  bool _sudahHabis = false;

  @override
  void initState() {
    super.initState();
    _hitung();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(_hitung);
    });
  }

  void _hitung() {
    final d = widget.expiresAt.difference(DateTime.now());
    _sisa = d.isNegative ? Duration.zero : d;
    if (_sisa == Duration.zero && !_sudahHabis) {
      _sudahHabis = true;
      _timer?.cancel();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onExpired?.call();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cta.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, color: AppStatusColors.warning),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Bayar di kasir sebelum waktu habis',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            formatSisaWaktu(_sisa),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppStatusColors.warning,
            ),
          ),
        ],
      ),
    );
  }
}
