import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../models/product.dart';
import '../services/product_service.dart';

class ProductRoutes {
  final ProductService _productService;

  ProductRoutes({
    ProductService? productService,
  }) : _productService =
            productService ?? ProductService();

  Router get router {
    final router = Router();

    router.get('/', _getProducts);
    router.get('/<id|[0-9]+>', _getProduct);

    return router;
  }

  Future<Response> _getProducts(
    Request request,
  ) async {
    try {
      final products =
          await _productService.getProducts();

      return _jsonResponse(
        200,
        {
          'products': products
              .map((product) => product.toMap())
              .toList(),
        },
      );
    } catch (e) {
      return _jsonResponse(
        500,
        {
          'message': 'Failed to load products.',
          'error': e.toString(),
        },
      );
    }
  }

  Future<Response> _getProduct(
    Request request,
    String id,
  ) async {
    try {
      final product = await _productService.getProduct(
        int.parse(id),
      );

      return _jsonResponse(
        200,
        {
          'product': product.toMap(),
        },
      );
    } catch (e) {
      return _jsonResponse(
        404,
        {
          'message': 'Product not found.',
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