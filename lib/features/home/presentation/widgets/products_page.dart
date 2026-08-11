import 'package:flutter/material.dart';

import '../widgets/product_card.dart';
import '../../../product/data/product_model.dart';
import '../../../product/data/dummy_products.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({
    super.key,
    required this.displayedProducts,
  });

  final List<Product> displayedProducts;

  @override
  Widget build(BuildContext context) {
    if (displayedProducts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(
          vertical: 40,
        ),
        child: Text(
          'No products found in this category.',
        ),
      );
    }

    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: displayedProducts.length,
        separatorBuilder: (context, index) {
          return const SizedBox(width: 16);
        },
        itemBuilder: (context, index) {
          return ProductCard(
            product: displayedProducts[index],
          );
        },
      ),
    );
  }
}