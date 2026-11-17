import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Tombol – jumlah + .
class QtyStepper extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const QtyStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 99,
  });

  Widget _tombol(IconData icon, VoidCallback? onPressed) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      iconSize: 18,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
      color: AppColors.primary,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _tombol(Icons.remove, value > min ? () => onChanged(value - 1) : null),
          SizedBox(
            width: 28,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          _tombol(Icons.add, value < max ? () => onChanged(value + 1) : null),
        ],
      ),
    );
  }
}
