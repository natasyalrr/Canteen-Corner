
import 'package:flutter/material.dart';

class MenuSearch extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const MenuSearch({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  static const Color primaryColor = Color(0xFF176B78);
  static const Color accentColor = Color(0xFF4CA3B5);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Cari makanan atau minuman...',
        hintStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: primaryColor,
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            controller.clear();
            onChanged('');
          },
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: accentColor,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
