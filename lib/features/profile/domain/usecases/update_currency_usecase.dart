import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateCurrencyUsecase {
  UpdateCurrencyUsecase(this._repository);

  final ProfileRepository _repository;

  Future<ProfileEntity> call({
    required String currencyCode,
  }) {
    return _repository.updateCurrency(currencyCode: currencyCode);
  }
}

