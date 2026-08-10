
import '../database/database.dart';
import '../models/user.dart';

class UserRepository {
  final DatabaseConnection _database;

  UserRepository({
    DatabaseConnection? database,
  }) : _database = database ?? DatabaseConnection.instance;

  Future<User?> findByEmail(String email) async {
    const sql = '''
      SELECT
        Id,
        Name,
        Email,
        PasswordHash,
        CreatedAt
      FROM Users
      WHERE Email = @email
    ''';

    final result = await _database.query(
      sql,
      parameters: {
        'email': email,
      },
    );

    final rows = result.rows;

    if (rows.isEmpty) {
      return null;
    }

    final row = rows.first;

    return User.fromMap({
      'Id': row['Id'],
      'Name': row['Name'],
      'Email': row['Email'],
      'PasswordHash': row['PasswordHash'],
      'CreatedAt': row['CreatedAt'],
    });
  }

  Future<User> create({
    required String name,
    required String email,
    required String passwordHash,
  }) async {
    const sql = '''
      INSERT INTO Users (
        Name,
        Email,
        PasswordHash
      )
      OUTPUT
        INSERTED.Id,
        INSERTED.Name,
        INSERTED.Email,
        INSERTED.PasswordHash,
        INSERTED.CreatedAt
      VALUES (
        @name,
        @email,
        @passwordHash
      )
    ''';

    final result = await _database.query(
      sql,
      parameters: {
        'name': name,
        'email': email,
        'passwordHash': passwordHash,
      },
    );

    final rows = result.rows;

    if (rows.isEmpty) {
      throw Exception('Failed to create user.');
    }

    final row = rows.first;

    return User.fromMap({
      'Id': row['Id'],
      'Name': row['Name'],
      'Email': row['Email'],
      'PasswordHash': row['PasswordHash'],
      'CreatedAt': row['CreatedAt'],
    });
  }
}
