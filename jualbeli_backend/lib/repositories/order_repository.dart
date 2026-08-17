import '../database/database.dart';

class OrderRepository {
  OrderRepository._();

  static final OrderRepository instance =
      OrderRepository._();

  final DatabaseConnection _db =
      DatabaseConnection.instance;

  Future<int> createOrder({
      required String email,
    }) async {
      // ------------------------------------------------------------
      // Check that the cart is not empty
      // ------------------------------------------------------------

      final cartResult = await _db.query(
        '''
        SELECT
            c.ProductId,
            c.Quantity,
            p.price
        FROM CartItems c
        INNER JOIN Products p
            ON p.Id = c.ProductId
        WHERE c.UserEmail = @email
        ''',
        parameters: {
          'email': email,
        },
      );

      if (cartResult.rows.isEmpty) {
        throw Exception(
          'Cart is empty.',
        );
      }

      // ------------------------------------------------------------
      // Calculate total amount
      // ------------------------------------------------------------

      final totalResult = await _db.query(
        '''
        SELECT
            SUM(
                CAST(p.price AS DECIMAL(30,2))
                * c.quantity
            ) AS totalAmount
        FROM CartItems c
        INNER JOIN Products p
            ON p.Id = c.ProductId
        WHERE c.UserEmail = @email
        ''',
        parameters: {
          'email': email,
        },
      );

      if (totalResult.rows.isEmpty) {
        throw Exception(
          'Failed to calculate Orders total.',
        );
      }

      final totalAmount =
          totalResult.rows.first['totalAmount'];

      if (totalAmount == null) {
        throw Exception(
          'Orders total is null.',
        );
      }

      // ------------------------------------------------------------
      // Create Orders
      // ------------------------------------------------------------

      final OrderResult = await _db.query(
        '''
        INSERT INTO Orders (
            email,
            total_amount,
            status
        )
        OUTPUT INSERTED.id AS OrderId
        VALUES (
            @email,
            @totalAmount,
            'Pending'
        );
        ''',
        parameters: {
          'email': email,
          'totalAmount': totalAmount,
        },
      );

      if (OrderResult.rows.isEmpty) {
        throw Exception(
          'Failed to create Orders.',
        );
      }

      final OrderId =
          OrderResult.rows.first['OrderId'];

      if (OrderId == null) {
        throw Exception(
          'Orders ID was not returned.',
        );
      }

      final parsedOrderId =
          int.parse(OrderId.toString());

      // ------------------------------------------------------------
      // Create OrderItems
      // ------------------------------------------------------------

      await _db.execute(
        '''
        INSERT INTO OrderItems (
            order_id,
            product_id,
            quantity,
            price
        )
        SELECT
            @OrderId,
            c.ProductId,
            c.quantity,
            p.price
        FROM CartItems c
        INNER JOIN Products p
            ON p.Id = c.ProductId
        WHERE c.UserEmail = @email;
        ''',
        parameters: {
          'OrderId': parsedOrderId,
          'email': email,
        },
      );

      // ------------------------------------------------------------
      // Clear cart
      // ------------------------------------------------------------

      await _db.execute(
        '''
        DELETE FROM CartItems
        WHERE UserEmail = @email;
        ''',
        parameters: {
          'email': email,
        },
      );

      // ------------------------------------------------------------
      // Return Orders ID
      // ------------------------------------------------------------

      return parsedOrderId;
    }

    Future<List<Map<String, dynamic>>> getOrdersForUser(
    String email,
  ) async {
    final result = await _db.query(
      '''
      SELECT
          id,
          email,
          total_amount,
          status,
          created_at
      FROM Orders
      WHERE email = @email
      ORDER BY created_at DESC, id DESC
      ''',
      parameters: {
        'email': email,
      },
    );

    return result.rows.map((row) {
      return {
        'id': int.parse(row['id'].toString()),
        'email': row['email']?.toString() ?? '',
        'totalAmount': _number(row['total_amount']),
        'status': row['status']?.toString() ?? '',
        'createdAt': row['created_at']?.toString(),
      };
    }).toList();
  }

  Future<Map<String, dynamic>?> getOrderForUser({
    required int orderId,
    required String email,
  }) async {
    final orderResult = await _db.query(
      '''
      SELECT
          id,
          email,
          total_amount,
          status,
          created_at
      FROM Orders
      WHERE id = @orderId
        AND email = @email
      ''',
      parameters: {
        'orderId': orderId,
        'email': email,
      },
    );

    if (orderResult.rows.isEmpty) {
      return null;
    }

    final itemResult = await _db.query(
      '''
      SELECT
          oi.id,
          oi.order_id,
          oi.product_id,
          oi.quantity,
          oi.price,
          p.Name,
          p.Image
      FROM OrderItems oi
      LEFT JOIN Products p
          ON p.Id = oi.product_id
      WHERE oi.order_id = @orderId
      ORDER BY oi.id ASC
      ''',
      parameters: {
        'orderId': orderId,
      },
    );

    final order = orderResult.rows.first;

    return {
      'id': int.parse(order['id'].toString()),
      'email': order['email']?.toString() ?? '',
      'totalAmount': _number(order['total_amount']),
      'status': order['status']?.toString() ?? '',
      'createdAt': order['created_at']?.toString(),
      'items': itemResult.rows.map((row) {
        return {
          'id': int.parse(row['id'].toString()),
          'orderId': int.parse(row['order_id'].toString()),
          'productId': int.parse(row['product_id'].toString()),
          'quantity': int.parse(row['quantity'].toString()),
          'price': _number(row['price']),
          'name': row['Name']?.toString() ?? 'Product unavailable',
          'image': row['Image']?.toString(),
        };
      }).toList(),
    };
  }

  double _number(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }
}