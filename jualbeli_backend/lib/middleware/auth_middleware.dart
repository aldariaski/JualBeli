import 'dart:convert';

import 'package:shelf/shelf.dart';

import '../services/jwt_service.dart';

class AuthMiddleware {
  AuthMiddleware._();

  static Handler middleware(Handler innerHandler) {
    return (Request request) async {
      final authorization =
          request.headers['authorization'];

      // ------------------------------------------------------------
      // Authorization header missing
      // ------------------------------------------------------------

      if (authorization == null ||
          authorization.trim().isEmpty) {
        return _unauthorized(
          'Authorization token is required.',
        );
      }

      // ------------------------------------------------------------
      // Check Bearer format
      // ------------------------------------------------------------

      if (!authorization.startsWith('Bearer ')) {
        return _unauthorized(
          'Invalid authorization format.',
        );
      }

      final token =
          authorization.substring(7).trim();

      if (token.isEmpty) {
        return _unauthorized(
          'Authorization token is required.',
        );
      }

      // ------------------------------------------------------------
      // Verify JWT
      // ------------------------------------------------------------

      try {
        final payload =
            JwtService.instance.verifyToken(token);

        // ----------------------------------------------------------
        // Extract user information
        // ----------------------------------------------------------

        final userId =
            payload['sub'];

        final email =
            payload['email'];

        if (userId == null ||
            email == null) {
          return _unauthorized(
            'Invalid token payload.',
          );
        }

        // ----------------------------------------------------------
        // Add authenticated user to request context
        // ----------------------------------------------------------

        final updatedRequest =
            request.change(
          context: {
            ...request.context,
            'userId': userId,
            'userEmail': email,
            'jwtPayload': payload,
          },
        );

        return innerHandler(updatedRequest);
      } catch (e) {
        return _unauthorized(
          'Invalid or expired token.',
        );
      }
    };
  }

  static Response _unauthorized(
    String message,
  ) {
    return Response(
      401,
      body: jsonEncode({
        'message': message,
      }),
      headers: {
        'content-type': 'application/json',
      },
    );
  }
}