
import 'package:flutter/material.dart';

class CategoryFilter extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const CategoryFilter({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  static const Color primaryColor = Color(0xFF176B78);
  static const Color accentColor = Color(0xFF4CA3B5);

  final List<String> categories = const [
    'Semua',
    'Makanan',
    'Minuman',
    'Snack',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;

          return ChoiceChip(
            label: Text(category),
            selected: isSelected,
            onSelected: (_) {
              onCategorySelected(category);
            },
            selectedColor: primaryColor,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : primaryColor,
              fontWeight: FontWeight.w600,
            ),
            side: BorderSide(
              color: isSelected ? primaryColor : accentColor,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          );
        },
      ),
    );
  }
}
