import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.fullName,
    required super.email,
    required super.avatarUrl,
    required super.currencyCode,
    required super.notificationsEnabled,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: (map['id'] ?? '').toString(),
      fullName: (map['full_name'] ?? '-') as String,
      email: (map['email'] ?? '-') as String,
      avatarUrl: (map['avatar_url'] ?? '') as String,
      currencyCode: ((map['currency_code'] ?? 'USD') as String).toUpperCase(),
      notificationsEnabled:
          (map['notifications_enabled'] as bool?) ?? true,
    );
  }
}

