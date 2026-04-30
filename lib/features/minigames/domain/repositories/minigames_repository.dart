import '../entities/minigames_entity.dart';

abstract class MinigamesRepository {
  Future<VoucherEntity> claimVoucher(String userId);
  Future<bool> checkVoucherAvailability();
  Future<List<String>> getCollectedVouchers();
  Future<void> saveCollectedVoucher(String code);
  Future<bool> hasClaimedToday();
  Future<void> setHasClaimedToday();
  Future<void> resetData();
}
