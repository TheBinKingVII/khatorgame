import '../entities/auth_entity.dart';

abstract class AuthRepository {
  Future<AuthEntity> login({
    required String email,
    required String password,
  });

  Future<AuthEntity> register({
    required String fullName,
    required String email,
    required String password,
  });

  Future<void> logout();
}
