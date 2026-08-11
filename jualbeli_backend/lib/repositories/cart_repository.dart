import '../database/database.dart';
import '../models/cart_item.dart';

class CartRepository {
  final DatabaseConnection _database;

  CartRepository({
    DatabaseConnection? database,
  }) : _database =
            database ?? DatabaseConnection.instance;

  Future<List<CartItem>> findByUser(
    String userEmail,
  ) async {
    const sql = '''
      SELECT
        c.Id,
        c.UserEmail,
        c.ProductId,
        c.Quantity,
        p.Name AS ProductName,
        p.Price,
        p.Image,
        p.Category,
        p.SellerName,
        p.SellerEmail
      FROM CartItems c
      INNER JOIN Products p
        ON c.ProductId = p.Id
      WHERE c.UserEmail = @userEmail
      ORDER BY c.Id DESC
    ''';

    final result = await _database.query(
      sql,
      parameters: {
        'userEmail': userEmail,
      },
    );

    return result.rows.map((row) {
      return CartItem(
        id: row['Id'] as int,
        userEmail: row['UserEmail'] as String,
        productId: row['ProductId'] as int,
        quantity: row['Quantity'] as int,
        productName: row['ProductName'] as String,
        price: (row['Price'] as num).toDouble(),
        image: row['Image'] as String?,
        category: row['Category'] as String,
        sellerName: row['SellerName'] as String,
        sellerEmail: row['SellerEmail'] as String,
      );
    }).toList();
  }

  Future<void> addOrIncrease(
    String userEmail,
    int productId,
  ) async {
    const sql = '''
      IF EXISTS (
        SELECT 1
        FROM CartItems
        WHERE UserEmail = @userEmail
          AND ProductId = @productId
      )
      BEGIN
        UPDATE CartItems
        SET Quantity = Quantity + 1
        WHERE UserEmail = @userEmail
          AND ProductId = @productId
      END
      ELSE
      BEGIN
        INSERT INTO CartItems (
          UserEmail,
          ProductId,
          Quantity
        )
        VALUES (
          @userEmail,
          @productId,
          1
        )
      END
    ''';

    await _database.execute(
      sql,
      parameters: {
        'userEmail': userEmail,
        'productId': productId,
      },
    );
  }

  Future<void> updateQuantity(
    String userEmail,
    int productId,
    int quantity,
  ) async {
    if (quantity <= 0) {
      await remove(
        userEmail,
        productId,
      );
      return;
    }

    const sql = '''
      UPDATE CartItems
      SET Quantity = @quantity
      WHERE UserEmail = @userEmail
        AND ProductId = @productId
    ''';

    await _database.execute(
      sql,
      parameters: {
        'userEmail': userEmail,
        'productId': productId,
        'quantity': quantity,
      },
    );
  }

  Future<void> remove(
    String userEmail,
    int productId,
  ) async {
    const sql = '''
      DELETE FROM CartItems
      WHERE UserEmail = @userEmail
        AND ProductId = @productId
    ''';

    await _database.execute(
      sql,
      parameters: {
        'userEmail': userEmail,
        'productId': productId,
      },
    );
  }

  Future<void> clear(
    String userEmail,
  ) async {
    const sql = '''
      DELETE FROM CartItems
      WHERE UserEmail = @userEmail
    ''';

    await _database.execute(
      sql,
      parameters: {
        'userEmail': userEmail,
      },
    );
  }
}