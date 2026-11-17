import 'package:flutter/material.dart';

import '../models/order_model.dart';
import '../theme/app_theme.dart';
import '../theme/status_colors.dart';

/// Label status pesanan berwarna.
class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  static Color warna(String status) {
    switch (status) {
      case OrderStatus.menungguBayar:
        return AppStatusColors.warning;
      case OrderStatus.dibayar:
        return AppColors.secondary;
      case OrderStatus.diproses:
        return AppColors.primary;
      case OrderStatus.siapDiambil:
        return AppStatusColors.success;
      case OrderStatus.selesai:
        return AppStatusColors.neutral;
      case OrderStatus.dibatalkan:
      case OrderStatus.kedaluwarsa:
        return AppStatusColors.danger;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = warna(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        OrderStatus.label(status),
        style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}
