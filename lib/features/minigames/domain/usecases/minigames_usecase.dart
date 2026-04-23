import '../entities/minigames_entity.dart';
import '../repositories/minigames_repository.dart';

class MinigamesUsecase {
  final MinigamesRepository repository;

  MinigamesUsecase(this.repository);

  Future<String> claimVoucher(String userId) async {
    // 1. Ambil dari database Supabase (lewat remote)
    final VoucherEntity voucher = await repository.claimVoucher(userId);
    
    // 2. Simpan sejarahnya ke HP (lewat local) beserta UTC Time
    final timeStr = DateTime.now().toUtc().toIso8601String();
    await repository.saveCollectedVoucher("${voucher.code}#$timeStr");
    
    await repository.setHasClaimedToday();
    
    return voucher.code;
  }

  Future<List<String>> getCollectedVouchers() {
    return repository.getCollectedVouchers();
  }

  Future<bool> hasClaimedToday() {
    return repository.hasClaimedToday();
  }

  Future<void> resetData() {
    return repository.resetData();
  }
}
