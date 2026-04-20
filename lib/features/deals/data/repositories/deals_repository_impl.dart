import '../datasources/deals_remote_data_source.dart';
import '../../domain/entities/deals_entity.dart';
import '../../domain/repositories/deals_repository.dart';

class DealsRepositoryImpl implements DealsRepository {
  DealsRepositoryImpl({DealsRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? DealsRemoteDataSource();

  final DealsRemoteDataSource _remoteDataSource;

  @override
  Future<List<DealsEntity>> fetchDeals({
    required int pageNumber,
    int pageSize = 20,
    int? storeId,
  }) {
    return _remoteDataSource.fetchDeals(
      pageNumber: pageNumber,
      pageSize: pageSize,
      storeId: storeId,
    );
  }

  @override
  Future<DealsDetailEntity> fetchDealDetail(String dealId) {
    return _remoteDataSource.fetchDealDetail(dealId);
  }

  @override
  Future<List<StoreEntity>> fetchActiveStores() {
    return _remoteDataSource.fetchActiveStores();
  }

  @override
  Future<List<GameSearchEntity>> searchGamesByTitle({
    required String title,
    int limit = 20,
  }) {
    return _remoteDataSource.searchGamesByTitle(title: title, limit: limit);
  }
}
