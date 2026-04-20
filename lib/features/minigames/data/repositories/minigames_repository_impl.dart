import '../../domain/entities/minigames_entity.dart';
import '../../domain/repositories/minigames_repository.dart';
import '../datasources/minigames_local_data_source.dart';
import '../datasources/minigames_remote_data_source.dart';

class MinigamesRepositoryImpl implements MinigamesRepository {
  final MinigamesRemoteDataSource remoteDataSource;
  final MinigamesLocalDataSource localDataSource;

  MinigamesRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<VoucherEntity> claimVoucher(String userId) {
    return remoteDataSource.claimVoucher(userId);
  }

  @override
  Future<List<String>> getCollectedVouchers() {
    return localDataSource.getCollectedVouchers();
  }

  @override
  Future<bool> hasClaimedToday() {
    return localDataSource.hasClaimedToday();
  }

  @override
  Future<void> saveCollectedVoucher(String code) {
    return localDataSource.saveCollectedVoucher(code);
  }

  @override
  Future<void> setHasClaimedToday() {
    return localDataSource.setHasClaimedToday();
  }

  @override
  Future<void> resetData() {
    return localDataSource.resetData();
  }
}
