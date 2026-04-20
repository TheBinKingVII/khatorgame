import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class UploadAvatarUsecase {
  UploadAvatarUsecase(this._repository);

  final ProfileRepository _repository;

  Future<ProfileEntity> call({
    required String filePath,
  }) {
    return _repository.uploadAvatar(filePath: filePath);
  }
}

