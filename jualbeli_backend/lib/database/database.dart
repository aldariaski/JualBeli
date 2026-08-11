import 'dart:async';

import 'package:mssql/mssql.dart';

class DatabaseConnection {
  DatabaseConnection._();

  static final DatabaseConnection instance =
      DatabaseConnection._();

  MssqlConnection? _connection;

  String? _host;
  int? _port;
  String? _username;
  String? _password;
  String? _databaseName;

  bool _connecting = false;

  Future<void> _operationQueue =
      Future.value();

  Future<void> connect({
    required String host,
    required int port,
    required String databaseName,
    required String username,
    required String password,
  }) async {
    _host = host;
    _port = port;
    _databaseName = databaseName;
    _username = username;
    _password = password;

    await _connect();
  }

  Future<void> _connect() async {
    if (_connection != null &&
        _connection!.isOpen) {
      return;
    }

    if (_connecting) {
      while (_connecting) {
        await Future.delayed(
          const Duration(milliseconds: 50),
        );
      }

      return;
    }

    _connecting = true;

    print('Connecting to SQL Server...');
    print('Host: $_host');
    print('Port: $_port');
    print('Database: $_databaseName');

    try {
      _connection =
          await MssqlConnection.connect(
        host: _host!,
        port: _port!,
        user: _username!,
        password: _password!,
        database: _databaseName!,
        encrypt: true,
        trustServerCertificate: true,
        timeout: const Duration(seconds: 30),
      );

      print(
        '========== SQL SERVER CONNECTED ==========',
      );
      print(
        'Database connection successful!',
      );
      print(
        '==========================================',
      );
    } catch (e, stackTrace) {
      _connection = null;

      print(
        '========== SQL SERVER ERROR ==========',
      );
      print('Error: $e');
      print(
        'Type: ${e.runtimeType}',
      );
      print(
        'Stack trace: $stackTrace',
      );
      print(
        '======================================',
      );

      rethrow;
    } finally {
      _connecting = false;
    }
  }

  Future<T> _withLock<T>(
    Future<T> Function() operation,
  ) {
    final previous =
        _operationQueue;

    final completer =
        Completer<void>();

    _operationQueue =
        completer.future;

    return previous.then((_) async {
      try {
        return await operation();
      } finally {
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    });
  }

  Future<MssqlResult> query(
    String sql, {
    Map<String, Object?> parameters =
        const {},
  }) {
    return _withLock(() async {
      await _connect();

      try {
        return await _connection!.query(
          sql,
          parameters,
        );
      } catch (e) {
        print(
          'Database query failed: $e',
        );

        // The connection may have been
        // closed by SQL Server / the TLS
        // socket.
        _connection = null;

        // Reconnect and retry once.
        await _connect();

        return await _connection!.query(
          sql,
          parameters,
        );
      }
    });
  }

  Future<int> execute(
    String sql, {
    Map<String, Object?> parameters =
        const {},
  }) {
    return _withLock(() async {
      await _connect();

      try {
        return await _connection!.execute(
          sql,
          parameters,
        );
      } catch (e) {
        print(
          'Database execute failed: $e',
        );

        _connection = null;

        // Reconnect and retry once.
        await _connect();

        return await _connection!.execute(
          sql,
          parameters,
        );
      }
    });
  }

  Future<void> close() async {
    final connection =
        _connection;

    _connection = null;

    if (connection != null &&
        connection.isOpen) {
      try {
        await connection.close();
      } catch (e) {
        print(
          'Database close error: $e',
        );
      }
    }
  }
}