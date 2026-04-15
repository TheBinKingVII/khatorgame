import '../../domain/entities/auth_entity.dart';

class AuthModel extends AuthEntity {
  const AuthModel({
    required super.id,
    required super.email,
    super.fullName,
  });

  factory AuthModel.fromMap(Map<String, dynamic> map) {
    return AuthModel(
      id: map['id'] as String,
      email: map['email'] as String,
      fullName: map['full_name'] as String?,
    );
  }
}
