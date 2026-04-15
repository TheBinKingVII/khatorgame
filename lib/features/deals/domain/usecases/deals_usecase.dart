import '../entities/deals_entity.dart';
import '../repositories/deals_repository.dart';

class DealsUsecase {
  DealsUsecase(this._repository);

  final DealsRepository _repository;

  Future<List<DealsEntity>> getDeals({
    required int pageNumber,
    int pageSize = 20,
  }) {
    return _repository.fetchDeals(
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }

  Future<DealsDetailEntity> getDealDetail(String dealId) {
    return _repository.fetchDealDetail(dealId);
  }
}
