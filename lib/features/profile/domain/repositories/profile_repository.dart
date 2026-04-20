import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity> getProfile();

  Future<ProfileEntity> updateProfile({
    required String fullName,
  });

  Future<ProfileEntity> updateCurrency({
    required String currencyCode,
  });

  Future<ProfileEntity> updateNotification({
    required bool enabled,
  });

  Future<ProfileEntity> uploadAvatar({
    required String filePath,
  });
}

