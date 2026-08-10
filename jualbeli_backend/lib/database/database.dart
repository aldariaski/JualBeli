
import 'package:mssql/mssql.dart';

class DatabaseConnection {
  DatabaseConnection._();

  static final DatabaseConnection instance = DatabaseConnection._();

  MssqlConnection? _connection;

  Future<void> connect({
    required String host,
    required int port,
    required String databaseName,
    required String username,
    required String password,
  }) async {
    if (_connection != null && _connection!.isOpen) {
      return;
    }

    print('Connecting to SQL Server...');
    print('Host: $host');
    print('Port: $port');
    print('Database: $databaseName');

    try {
      _connection = await MssqlConnection.connect(
        host: host,
        port: port,
        user: username,
        password: password,
        database: databaseName,

        // Accept the local SQL Server self-signed certificate.
        encrypt: true,
        trustServerCertificate: true,

        timeout: const Duration(seconds: 30),
      );

      print('========== SQL SERVER CONNECTED ==========');
      print('Database connection successful!');
      print('==========================================');
    } catch (e, stackTrace) {
      print('========== SQL SERVER ERROR ==========');
      print('Error: $e');
      print('Type: ${e.runtimeType}');
      print('Stack trace: $stackTrace');
      print('======================================');

      rethrow;
    }
  }

  Future<MssqlResult> query(
    String sql, {
    Map<String, Object?> parameters = const {},
  }) async {
    if (_connection == null || !_connection!.isOpen) {
      throw StateError('Database is not connected.');
    }

    return await _connection!.query(
      sql,
      parameters,
    );
  }

  Future<int> execute(
    String sql, {
    Map<String, Object?> parameters = const {},
  }) async {
    if (_connection == null || !_connection!.isOpen) {
      throw StateError('Database is not connected.');
    }

    return await _connection!.execute(
      sql,
      parameters,
    );
  }

  Future<void> close() async {
    if (_connection != null && _connection!.isOpen) {
      await _connection!.close();
      _connection = null;
    }
  }
}

