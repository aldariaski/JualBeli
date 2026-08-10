
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class JwtService {
  static const String _secret =
      'JUALBELI_DEVELOPMENT_SECRET_CHANGE_THIS';

  static String generateToken({
    required int userId,
    required String email,
  }) {
    final jwt = JWT(
      {
        'userId': userId,
        'email': email,
      },
    );

    return jwt.sign(
      SecretKey(_secret),
      expiresIn: const Duration(days: 7),
    );
  }

  static JWT verifyToken(String token) {
    return JWT.verify(
      token,
      SecretKey(_secret),
    );
  }
}

