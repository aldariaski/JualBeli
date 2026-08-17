import 'package:flutter/material.dart';

import 'category_chip.dart';

class Categories extends StatefulWidget {
  const Categories({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  static const shopCategories = [
    'All',
    'Electronics',
    'Fashion',
    'Shoes',
    'Beauty',
    'Health',
    'Home & Living',
    'Furniture',
    'Sports',
    'Toys',
    'Books',
    'Food & Beverages',
    'Automotive',
    'Accessories',
    'Pet Supplies',
    'Baby & Kids',
    'Groceries',
    'Office & Stationery',
    'Tools & Hardware',
    'Other',
  ];

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: Categories.shopCategories.length,
        separatorBuilder: (context, index) {
          return const SizedBox(width: 8);
        },
        itemBuilder: (context, index) {
          final category =
              Categories.shopCategories[index];

          return CategoryChip(
            label: category,
            selected:
                widget.selectedCategory == category,
            onTap: () {
              widget.onCategorySelected(category);
            },
          );
        },
      ),
    );
  }
}