import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUsecase {
  UpdateProfileUsecase(this._repository);

  final ProfileRepository _repository;

  Future<ProfileEntity> call({
    required String fullName,
  }) {
    return _repository.updateProfile(fullName: fullName);
  }
}

