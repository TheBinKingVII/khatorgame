import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class GetProfileUsecase {
  GetProfileUsecase(this._repository);

  final ProfileRepository _repository;

  Future<ProfileEntity> call() {
    return _repository.getProfile();
  }
}

