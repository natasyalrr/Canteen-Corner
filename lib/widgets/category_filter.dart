import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CategoryFilter extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const CategoryFilter({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  static const categories = ['Semua', 'Makanan', 'Minuman', 'Snack'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final selected = selectedCategory == category;
          return ChoiceChip(
            label: Text(category),
            selected: selected,
            showCheckmark: false,
            onSelected: (_) => onCategorySelected(category),
            selectedColor: AppColors.secondary,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            side: BorderSide(
              color: selected ? AppColors.secondary : AppColors.accent,
            ),
          );
        },
      ),
    );
  }
}
