import 'package:bcrypt/bcrypt.dart';

import '../database/database.dart';
import '../models/user.dart';
import '../repositories/user_repository.dart';

class AuthService {
  final UserRepository _userRepository;

  AuthService({
    UserRepository? userRepository,
  }) : _userRepository = userRepository ??
            UserRepository(
              database: DatabaseConnection.instance,
            );

  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedName = name.trim();

    if (normalizedName.isEmpty) {
      throw Exception('Name is required.');
    }

    if (normalizedEmail.isEmpty) {
      throw Exception('Email is required.');
    }

    if (password.length < 6) {
      throw Exception(
        'Password must be at least 6 characters.',
      );
    }

    final existingUser =
        await _userRepository.findByEmail(normalizedEmail);

    if (existingUser != null) {
      throw Exception(
        'An account with this email already exists.',
      );
    }

    final passwordHash = BCrypt.hashpw(
      password,
      BCrypt.gensalt(),
    );

    return await _userRepository.create(
      name: normalizedName,
      email: normalizedEmail,
      passwordHash: passwordHash,
    );
  }

  Future<User> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    final user =
        await _userRepository.findByEmail(normalizedEmail);

    if (user == null) {
      throw Exception('Invalid email or password.');
    }

    final passwordValid = BCrypt.checkpw(
      password,
      user.passwordHash,
    );

    if (!passwordValid) {
      throw Exception('Invalid email or password.');
    }

    return user;
  }
}

