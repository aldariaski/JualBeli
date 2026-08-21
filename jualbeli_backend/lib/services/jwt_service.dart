import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class JwtService {
  JwtService._();

  static final JwtService instance = JwtService._();

  // IMPORTANT:
  // Replace this with a long random secret.
  // Do NOT commit the real secret to Git.
  static const String _secret =
      'CHANGE_THIS_TO_A_LONG_RANDOM_SECRET';

  static const String _issuer = 'jualbeli-backend';

  static const Duration _tokenLifetime =
      Duration(hours: 24);

  String generateToken({
    required int userId,
    required String email,
  }) {
    final jwt = JWT(
      {
        'sub': userId,
        'email': email,
      },
      issuer: _issuer,
    );

    return jwt.sign(
      SecretKey(_secret),
      expiresIn: _tokenLifetime,
    );
  }

  Map<String, dynamic> verifyToken(
    String token,
  ) {
    final jwt = JWT.verify(
      token,
      SecretKey(_secret),
      issuer: _issuer,
    );

    return Map<String, dynamic>.from(
      jwt.payload as Map,
    );
  }
}