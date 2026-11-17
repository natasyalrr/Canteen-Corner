import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Foto menu dari URL / aset, dengan placeholder bila kosong atau gagal dimuat.
class MenuImage extends StatelessWidget {
  final String url;
  final double iconSize;

  const MenuImage({super.key, required this.url, this.iconSize = 48});

  Widget _placeholder() {
    return Container(
      color: AppColors.accent.withValues(alpha: 0.35),
      alignment: Alignment.center,
      child: Icon(Icons.restaurant, size: iconSize, color: AppColors.primary),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return _placeholder();
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stack) => _placeholder(),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stack) => _placeholder(),
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : _placeholder(),
    );
  }
}
