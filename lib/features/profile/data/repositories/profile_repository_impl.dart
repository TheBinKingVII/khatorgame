import 'package:khatorgame/core/services/session_service.dart';

import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({
    required ProfileRemoteDataSource remoteDataSource,
    SessionService? sessionService,
  })  : _remote = remoteDataSource,
        _session = sessionService ?? SessionService.instance;

  final ProfileRemoteDataSource _remote;
  final SessionService _session;

  String get _userId {
    final String? id = _session.userId;
    if (id == null || id.isEmpty) {
      throw StateError('Belum login');
    }
    return id;
  }

  String get _userEmail {
    return _session.userEmail ?? '';
  }

  @override
  Future<ProfileEntity> getProfile() {
    return _remote.getOrCreateProfile(userId: _userId, userEmail: _userEmail);
  }

  @override
  Future<ProfileEntity> updateProfile({
    required String fullName,
  }) async {
    await _remote.updateUserFullName(
      userId: _userId,
      fullName: fullName,
    );
    return _remote.getOrCreateProfile(userId: _userId, userEmail: _userEmail);
  }

  @override
  Future<ProfileEntity> updateCurrency({
    required String currencyCode,
  }) {
    return _remote.updateProfile(
      userId: _userId,
      values: <String, dynamic>{
        'currency_code': currencyCode.toUpperCase(),
      },
    );
  }

  @override
  Future<ProfileEntity> updateNotification({
    required bool enabled,
  }) {
    return _remote.updateProfile(
      userId: _userId,
      values: <String, dynamic>{
        'notifications_enabled': enabled,
      },
    );
  }

  @override
  Future<ProfileEntity> uploadAvatar({
    required String filePath,
  }) async {
    final String avatarUrl = await _remote.uploadAvatarFile(
      userId: _userId,
      filePath: filePath,
    );

    return _remote.updateProfile(
      userId: _userId,
      values: <String, dynamic>{
        'avatar_url': avatarUrl,
      },
    );
  }
}

