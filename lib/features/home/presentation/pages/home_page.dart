import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_search_bar.dart';

import '../../../product/data/product_api_service.dart';
import '../../../product/data/product_model.dart';

import '../widgets/categories.dart';
import '../widgets/products_page.dart';
import '../widgets/section_title.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProductApiService _productApiService =
      ProductApiService();

  String selectedCategory = 'All';

  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();

    _productsFuture =
        _productApiService.getProducts();
  }

  List<Product> filterProducts(
    List<Product> products,
  ) {
    if (selectedCategory == 'All') {
      return products;
    }

    return products
        .where(
          (product) =>
              product.category == selectedCategory,
        )
        .toList();
  }

  Future<void> _refreshProducts() async {
    setState(() {
      _productsFuture =
          _productApiService.getProducts();
    });

    await _productsFuture;
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

                  FutureBuilder<List<Product>>(
                    future: _productsFuture,
                    builder: (
                      context,
                      snapshot,
                    ) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const SizedBox(
                          height: 240,
                          child: Center(
                            child:
                                CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return SizedBox(
                          height: 240,
                          child: Center(
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Unable to load products.',
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed:
                                      _refreshProducts,
                                  child: const Text(
                                    'Retry',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final products =
                          snapshot.data ?? [];

                      final displayedProducts =
                          filterProducts(products);

                      return ProductsPage(
                        displayedProducts:
                            displayedProducts,
                      );
                    },
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