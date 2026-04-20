import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:khatorgame/core/services/biometric_auth_service.dart';
import 'package:khatorgame/core/services/session_service.dart';
import 'package:khatorgame/features/profile/presentation/controllers/profile_controller.dart';
import 'package:khatorgame/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:khatorgame/features/wishlist/presentation/controllers/wishlist_controller.dart';

import '../datasources/auth_remote_data_source.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    AuthRemoteDataSource? remoteDataSource,
    SessionService? sessionService,
  }) : _remoteDataSource = remoteDataSource ?? AuthRemoteDataSource(),
       _sessionService = sessionService ?? SessionService.instance;

  final AuthRemoteDataSource _remoteDataSource;
  final SessionService _sessionService;
  final BiometricAuthService _biometricService = BiometricAuthService.instance;

  @override
  Future<AuthEntity> login({
    required String email,
    required String password,
  }) async {
    final AuthEntity user = await _remoteDataSource.login(
      email: email,
      password: password,
    );

    await _sessionService.saveLogin(userId: user.id, userEmail: user.email);

    await _postLoginSync();

    return user;
  }

  Future<AuthEntity> loginWithBiometric() async {
    final BiometricIdentity? identity = await _biometricService
        .getSavedIdentity();
    if (identity == null) {
      throw Exception('Biometrik belum diaktifkan');
    }

    final bool authenticated = await _biometricService.authenticateForLogin();
    if (!authenticated) {
      throw Exception('Verifikasi biometrik dibatalkan atau gagal');
    }

    await _sessionService.saveLogin(
      userId: identity.userId,
      userEmail: identity.userEmail,
    );
    await _postLoginSync();
    return AuthEntity(id: identity.userId, email: identity.userEmail);
  }

  Future<bool> canShowBiometricLogin() async {
    final BiometricIdentity? identity = await _biometricService
        .getSavedIdentity();
    final bool canUseDeviceBiometric = await _biometricService
        .canUseBiometric();
    return identity != null && canUseDeviceBiometric;
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
    if (Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().clearState();
    }
  }

  Future<void> _postLoginSync() async {
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
    if (Get.isRegistered<ProfileController>()) {
      await Get.find<ProfileController>().loadProfile();
    }
  }
}
