import 'package:flutter/material.dart';

import 'category_chip.dart';
import '../../../product/data/dummy_products.dart';

class Categories extends StatelessWidget {
  const Categories({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  static const shopCategories = Product.shopCategories;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: shopCategories.length,
        separatorBuilder: (context, index) {
          return const SizedBox(width: 8);
        },
        itemBuilder: (context, index) {
          final category = shopCategories[index];

          return CategoryChip(
            label: category,
            selected: selectedCategory == category,
            onTap: () {
              onCategorySelected(category);
            },
          );
        },
      ),
    );
  }
}