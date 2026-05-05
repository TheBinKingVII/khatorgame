import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class AuthUsecase {
  AuthUsecase(this._repository);

  final AuthRepository _repository;

  Future<AuthEntity> login({
    required String email,
    required String password,
  }) {
    return _repository.login(email: email, password: password);
  }

  Future<AuthEntity> register({
    required String fullName,
    required String email,
    required String password,
  }) {
    return _repository.register(
      fullName: fullName,
      email: email,
      password: password,
    );
  }

  Future<AuthEntity> loginWithBiometric() {
    return _repository.loginWithBiometric();
  }

  Future<bool> canShowBiometricLogin() {
    return _repository.canShowBiometricLogin();
  }

  Future<void> logout() {
    return _repository.logout();
  }
}
