import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:khatorgame/core/services/session_service.dart';
import 'package:khatorgame/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:khatorgame/features/wishlist/presentation/controllers/wishlist_controller.dart';

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

    if (Get.isRegistered<WishlistRepository>()) {
      try {
        await Get.find<WishlistRepository>().syncFromRemote();
      } catch (error, stackTrace) {
        debugPrint('Wishlist sync after login: $error\n$stackTrace');
      }
    }
    if (Get.isRegistered<WishlistController>()) {
      await Get.find<WishlistController>().refreshFromLocal();
    }

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
  Future<void> logout() async {
    final String? userId = _sessionService.userId;
    if (userId != null && Get.isRegistered<WishlistRepository>()) {
      await Get.find<WishlistRepository>().clearLocalForUser(userId);
    }
    await _sessionService.clearSession();
    if (Get.isRegistered<WishlistController>()) {
      Get.find<WishlistController>().clearState();
    }
  }
}
