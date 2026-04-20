class VoucherEntity {
  final String id;
  final String code;
  final int nominal;
  final String? userId;

  VoucherEntity({
    required this.id,
    required this.code,
    required this.nominal,
    this.userId,
  });
}
