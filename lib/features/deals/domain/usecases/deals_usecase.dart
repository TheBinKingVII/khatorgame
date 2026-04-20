import '../entities/deals_entity.dart';
import '../repositories/deals_repository.dart';

class DealsUsecase {
  DealsUsecase(this._repository);

  final DealsRepository _repository;

  Future<List<DealsEntity>> getDeals({
    required int pageNumber,
    int pageSize = 20,
    int? storeId,
  }) {
    return _repository.fetchDeals(
      pageNumber: pageNumber,
      pageSize: pageSize,
      storeId: storeId,
    );
  }

  Future<DealsDetailEntity> getDealDetail(String dealId) {
    return _repository.fetchDealDetail(dealId);
  }

  Future<List<StoreEntity>> getActiveStores() {
    return _repository.fetchActiveStores();
  }

  Future<List<GameSearchEntity>> searchGamesByTitle({
    required String title,
    int limit = 20,
  }) {
    return _repository.searchGamesByTitle(title: title, limit: limit);
  }
}
