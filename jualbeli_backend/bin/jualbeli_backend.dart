
import 'dart:io';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import 'package:jualbeli_backend/config/database_config.dart';
import 'package:jualbeli_backend/database/database.dart';
import 'package:jualbeli_backend/routes/auth_routes.dart';
import 'package:jualbeli_backend/routes/product_routes.dart';
import 'package:jualbeli_backend/routes/cart_routes.dart';
import 'package:jualbeli_backend/routes/order_routes.dart';


Future<void> main() async {
  final database = DatabaseConnection.instance;

  await database.connect(
    host: DatabaseConfig.host,
    port: DatabaseConfig.port,
    databaseName: DatabaseConfig.databaseName,
    username: DatabaseConfig.username,
    password: DatabaseConfig.password,
  );

  final router = Router();

  router.get('/', (Request request) {
    return Response.ok(
      'JualBeli Backend is running.',
    );
  });

  router.mount(
    '/auth/',
    AuthRoutes().router.call,
  );
  
   router.mount(
    '/products/',
    ProductRoutes().router.call,
  );

  router.mount(
    '/cart/',
    CartRoutes().router.call,
  );

  router.mount(
    '/orders/',
    OrderRoutes.instance.router.call,
  );

  final handler = const Pipeline()
      .addMiddleware(corsHeaders())
      .addMiddleware(logRequests())
      .addHandler(router.call);

  final server = await shelf_io.serve(
    handler,
    InternetAddress.anyIPv4,
    8080,
  );

  print(
    'JualBeli backend running on '
    'http://${server.address.host}:${server.port}',
  );
}

