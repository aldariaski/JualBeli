import 'package:flutter/material.dart';

import '../../../shared/widgets/app_search_bar.dart';

import '../widgets/categories.dart';
import '../widgets/section_title.dart';
import '../../../product/data/dummy_products.dart';

import '../widgets/products_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedCategory = 'All';

  List<Product> get displayedProducts {
    if (selectedCategory == 'All') {
      return products;
    }

    return products
        .where(
          (product) => product.category == selectedCategory,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            const AppSearchBar(),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  const Text(
                    'Welcome!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Find the best products for you.',
                  ),

                  const SizedBox(height: 32),

                  const SectionTitle(
                    title: 'Categories',
                  ),

                  const SizedBox(height: 12),

                  Categories(
                    selectedCategory: selectedCategory,
                    onCategorySelected: (category) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                  ),

                  const SizedBox(height: 32),

                  SectionTitle(
                    title: selectedCategory == 'All'
                        ? 'Featured Products'
                        : selectedCategory,
                  ),

                  const SizedBox(height: 12),

                  ProductsPage(
                    displayedProducts: displayedProducts,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}