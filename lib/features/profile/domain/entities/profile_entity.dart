class ProfileEntity {
  const ProfileEntity({
    required this.id,
    required this.fullName,
    required this.email,
    required this.avatarUrl,
    required this.currencyCode,
    required this.notificationsEnabled,
  });

  final String id;
  final String fullName;
  final String email;
  final String avatarUrl;
  final String currencyCode;
  final bool notificationsEnabled;
}

