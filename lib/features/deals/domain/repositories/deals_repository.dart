import '../entities/deals_entity.dart';

abstract class DealsRepository {
  Future<List<DealsEntity>> fetchDeals({
    required int pageNumber,
    int pageSize,
    int? storeId,
  });

  Future<DealsDetailEntity> fetchDealDetail(String dealId);

  Future<List<StoreEntity>> fetchActiveStores();

  Future<List<GameSearchEntity>> searchGamesByTitle({
    required String title,
    int limit,
  });
}
