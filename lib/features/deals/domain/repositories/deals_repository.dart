import '../entities/deals_entity.dart';

abstract class DealsRepository {
  Future<List<DealsEntity>> fetchDeals({
    required int pageNumber,
    int pageSize,
  });

  Future<DealsDetailEntity> fetchDealDetail(String dealId);
}
