import 'package:khatorgame/core/services/session_service.dart';

import '../datasources/auth_remote_data_source.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    AuthRemoteDataSource? remoteDataSource,
    SessionService? sessionService,
  })  : _remoteDataSource = remoteDataSource ?? AuthRemoteDataSource(),
        _sessionService = sessionService ?? SessionService.instance;

  final AuthRemoteDataSource _remoteDataSource;
  final SessionService _sessionService;

  @override
  Future<AuthEntity> login({
    required String email,
    required String password,
  }) async {
    final AuthEntity user = await _remoteDataSource.login(
      email: email,
      password: password,
    );

    await _sessionService.saveLogin(
      userId: user.id,
      userEmail: user.email,
    );

    return user;
  }

  @override
  Future<AuthEntity> register({
    required String fullName,
    required String email,
    required String password,
  }) {
    return _remoteDataSource.register(
      fullName: fullName,
      email: email,
      password: password,
    );
  }

  @override
  Future<void> logout() {
    return _sessionService.clearSession();
  }
}
