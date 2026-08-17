import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../repositories/order_repository.dart';

class OrderRoutes {
  OrderRoutes._();

  static final OrderRoutes instance = OrderRoutes._();

  final OrderRepository _repository = OrderRepository.instance;

  Router get router {
    final router = Router();

    // Existing checkout route
    router.post('/', _createOrder);
    router.get('/', _getOrders);
    router.get('/<id|[0-9]+>', _getOrder);

    return router;
  }

  Future<Response> _createOrder(
    Request request,
  ) async {
    try {
      final body =
          await request.readAsString();

      final data =
          jsonDecode(body);

      if (data is! Map<String, dynamic>) {
        return Response(
          400,
          body: jsonEncode({
            'error': 'Invalid request body.',
          }),
          headers: {
            'Content-Type':
                'application/json',
          },
        );
      }

      final email = data['email'];

      if (email == null ||
          email.toString().trim().isEmpty) {
        return Response(
          400,
          body: jsonEncode({
            'error': 'Email is required.',
          }),
          headers: {
            'Content-Type':
                'application/json',
          },
        );
      }

      final orderId =
          await _repository.createOrder(
        email: email.toString(),
      );

      return Response(
        201,
        body: jsonEncode({
          'message':
              'Order created successfully.',
          'orderId': orderId,
        }),
        headers: {
          'Content-Type':
              'application/json',
        },
      );
    } catch (e) {
      print(
        'Create order error: $e',
      );

      return Response(
        500,
        body: jsonEncode({
          'error':
              'Failed to create order.',
          'details': e.toString(),
        }),
        headers: {
          'Content-Type':
              'application/json',
        },
      );
    }
  }

  Future<Response> _getOrders(Request request) async {
    try {
      final email = request.url.queryParameters['email'];

      if (email == null || email.trim().isEmpty) {
        return _jsonResponse(
          400,
          {'error': 'Email is required.'},
        );
      }

      final orders = await _repository.getOrdersForUser(email);

      return _jsonResponse(
        200,
        {
          'orders': orders,
        },
      );
    } catch (e) {
      print('Get orders error: $e');

      return _jsonResponse(
        500,
        {
          'error': 'Failed to load orders.',
          'details': e.toString(),
        },
      );
    }
  }

  Future<Response> _getOrder(
    Request request,
    String id,
  ) async {
    try {
      final email = request.url.queryParameters['email'];

      if (email == null || email.trim().isEmpty) {
        return _jsonResponse(
          400,
          {'error': 'Email is required.'},
        );
      }

      final order = await _repository.getOrderForUser(
        orderId: int.parse(id),
        email: email,
      );

      if (order == null) {
        return _jsonResponse(
          404,
          {'error': 'Order not found.'},
        );
      }

      return _jsonResponse(
        200,
        {
          'order': order,
        },
      );
    } catch (e) {
      print('Get order error: $e');

      return _jsonResponse(
        500,
        {
          'error': 'Failed to load order.',
          'details': e.toString(),
        },
      );
    }
  }

  Response _jsonResponse(
    int statusCode,
    Map<String, dynamic> body,
  ) {
    return Response(
      statusCode,
      body: jsonEncode(body),
      headers: {
        'content-type': 'application/json',
      },
    );
  }
}