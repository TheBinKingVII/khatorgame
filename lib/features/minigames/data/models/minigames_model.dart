import '../../domain/entities/minigames_entity.dart';

class VoucherModel extends VoucherEntity {
  VoucherModel({
    required super.id,
    required super.code,
    required super.nominal,
    super.userId,
  });

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    return VoucherModel(
      id: json['id'] as String,
      code: json['code'] as String,
      nominal: json['nominal'] != null ? json['nominal'] as int : 0,
      userId: json['user_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'nominal': nominal,
      'user_id': userId,
    };
  }
}
