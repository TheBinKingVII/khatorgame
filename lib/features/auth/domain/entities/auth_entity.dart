class AuthEntity {
  const AuthEntity({
    required this.id,
    required this.email,
    this.fullName,
  });

  final String id;
  final String email;
  final String? fullName;
}
