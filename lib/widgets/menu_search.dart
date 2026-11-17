import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class MenuSearch extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const MenuSearch({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Cari makanan, minuman, atau kantin',
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: const Icon(Icons.search, color: AppColors.primary),
        suffixIcon: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            controller.clear();
            onChanged('');
          },
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
