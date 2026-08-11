import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../product/data/product_model.dart';
import 'cart_item.dart';

class CartService {
  CartService._();

  static final CartService instance = CartService._();

  static const String baseUrl = 'http://localhost:8080';

  Future<List<CartItem>> getCart(
    String email,
  ) async {
    final uri = Uri.parse(
      '$baseUrl/cart/'
      '?email=${Uri.encodeQueryComponent(email)}',
    );

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load cart: '
        '${response.statusCode} '
        '${response.body}',
      );
    }

    final data = jsonDecode(response.body);

    if (data is! Map<String, dynamic>) {
      throw Exception(
        'Invalid cart response.',
      );
    }

    final items = data['items'];

    if (items is! List) {
      return [];
    }

    return items
        .map(
          (item) => CartItem.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<void> addProduct(
    String email,
    Product product,
  ) async {
    final uri = Uri.parse(
      '$baseUrl/cart/',
    );

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'productId': product.id,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to add product to cart: '
        '${response.statusCode} '
        '${response.body}',
      );
    }
  }

  Future<void> updateQuantity(
    String email,
    int productId,
    int quantity,
  ) async {
    if (quantity <= 0) {
      await removeProduct(
        email,
        productId,
      );
      return;
    }

    final uri = Uri.parse(
      '$baseUrl/cart/$productId',
    );

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'quantity': quantity,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update cart: '
        '${response.statusCode} '
        '${response.body}',
      );
    }
  }

  Future<void> removeProduct(
    String email,
    int productId,
  ) async {
    final uri = Uri.parse(
      '$baseUrl/cart/$productId'
      '?email=${Uri.encodeQueryComponent(email)}',
    );

    final response = await http.delete(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to remove product: '
        '${response.statusCode} '
        '${response.body}',
      );
    }
  }

  Future<void> clearCart(
    String email,
  ) async {
    final uri = Uri.parse(
      '$baseUrl/cart/'
      '?email=${Uri.encodeQueryComponent(email)}',
    );

    final response = await http.delete(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to clear cart: '
        '${response.statusCode} '
        '${response.body}',
      );
    }
  }
}