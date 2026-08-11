import '../database/database.dart';
import '../models/product.dart';

class ProductRepository {
  final DatabaseConnection _database;

  ProductRepository({
    DatabaseConnection? database,
  }) : _database = database ?? DatabaseConnection.instance;

  Future<List<Product>> getAll() async {
    const sql = '''
      SELECT
        Id,
        Name,
        Price,
        Image,
        Category,
        SellerName,
        SellerEmail
      FROM Products
      ORDER BY Id DESC
    ''';

    final result = await _database.query(sql);

    return result.rows.map((row) {
      return Product.fromMap({
        'Id': row['Id'],
        'Name': row['Name'],
        'Price': row['Price'],
        'Image': row['Image'],
        'Category': row['Category'],
        'SellerName': row['SellerName'],
        'SellerEmail': row['SellerEmail'],
      });
    }).toList();
  }

  Future<Product?> findById(int id) async {
    const sql = '''
      SELECT
        Id,
        Name,
        Price,
        Image,
        Category,
        SellerName,
        SellerEmail
      FROM Products
      WHERE Id = @id
    ''';

    final result = await _database.query(
      sql,
      parameters: {
        'id': id,
      },
    );

    if (result.rows.isEmpty) {
      return null;
    }

    final row = result.rows.first;

    return Product.fromMap({
      'Id': row['Id'],
      'Name': row['Name'],
      'Price': row['Price'],
      'Image': row['Image'],
      'Category': row['Category'],
      'SellerName': row['SellerName'],
      'SellerEmail': row['SellerEmail'],
    });
  }
}