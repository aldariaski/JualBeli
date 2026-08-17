import 'dart:convert';
import 'package:http/http.dart' as http;
import 'order_model.dart';

class OrderService {
  OrderService._();
  static final OrderService instance = OrderService._();
  static const String baseUrl = 'http://localhost:8080';

  Future<List<Order>> getOrders(String email) async {
    final uri = Uri.parse('$baseUrl/orders/?email=${Uri.encodeQueryComponent(email)}');
    final response = await http.get(uri, headers: {'Content-Type': 'application/json'});
    if (response.statusCode != 200) {
      throw Exception('Failed to load orders: ${response.statusCode} ${response.body}');
    }
    final data = jsonDecode(response.body);
    if (data is! Map<String, dynamic> || data['orders'] is! List) {
      throw Exception('Invalid orders response.');
    }
    return (data['orders'] as List)
        .map((item) => Order.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<Map<String, dynamic>> getOrder(String email, int orderId) async {
    final uri = Uri.parse('$baseUrl/orders/$orderId?email=${Uri.encodeQueryComponent(email)}');
    final response = await http.get(uri, headers: {'Content-Type': 'application/json'});
    if (response.statusCode != 200) {
      throw Exception('Failed to load order: ${response.statusCode} ${response.body}');
    }
    final data = jsonDecode(response.body);
    if (data is! Map<String, dynamic> || data['order'] is! Map) {
      throw Exception('Invalid order response.');
    }
    return Map<String, dynamic>.from(data['order']);
  }
}
