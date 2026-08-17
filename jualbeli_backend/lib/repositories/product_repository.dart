import '../database/database.dart';
import '../models/product.dart';

class ProductRepository {
  final DatabaseConnection _database;

  ProductRepository({
    DatabaseConnection? database,
  }) : _database = database ?? DatabaseConnection.instance;

    Future<Product> createProduct({
      required String name,
      required double price,
      String? image,
      required String category,
      required String sellerName,
      required String sellerEmail,
    }) async {
      String escapeSql(String value) {
        return value.replaceAll("'", "''");
      }

      final nameValue = escapeSql(name);
      final categoryValue = escapeSql(category);
      final sellerNameValue = escapeSql(sellerName);
      final sellerEmailValue = escapeSql(sellerEmail);

      final imageValue = image == null || image.isEmpty
          ? 'NULL'
          : "N'${escapeSql(image)}'";

      final result = await _database.query(
        '''
        INSERT INTO Products
        (
          Name,
          Price,
          Image,
          Category,
          SellerName,
          SellerEmail
        )
        OUTPUT
          INSERTED.Id,
          INSERTED.Name,
          INSERTED.Price,
          INSERTED.Image,
          INSERTED.Category,
          INSERTED.SellerName,
          INSERTED.SellerEmail
        VALUES
        (
          N'$nameValue',
          $price,
          $imageValue,
          N'$categoryValue',
          N'$sellerNameValue',
          N'$sellerEmailValue'
        )
        ''',
      );

      if (result.isEmpty) {
        throw Exception('Failed to create product.');
      }

      final row = result.rows.first;

      return Product.fromMap(
        {
          'Id': row['Id'],
          'Name': row['Name'],
          'Price': row['Price'],
          'Image': row['Image'],
          'Category': row['Category'],
          'SellerName': row['SellerName'],
          'SellerEmail': row['SellerEmail'],
        },
      );
    }

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