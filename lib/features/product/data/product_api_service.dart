import 'dart:convert';

import 'package:http/http.dart' as http;

import 'product_model.dart';

class ProductApiService {
  static const String baseUrl = 'http://localhost:8080';

  Future<List<Product>> getProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load products: ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body);

    final List products = data['products'];

    return products
        .map(
          (json) => Product.fromJson(
            Map<String, dynamic>.from(json),
          ),
        )
        .toList();
  }

  Future<Product> getProduct(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load product: ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body);

    return Product.fromJson(
      Map<String, dynamic>.from(data['product']),
    );
  }
}