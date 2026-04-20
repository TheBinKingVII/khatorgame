import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateNotificationUsecase {
  UpdateNotificationUsecase(this._repository);

  final ProfileRepository _repository;

  Future<ProfileEntity> call({
    required bool enabled,
  }) {
    return _repository.updateNotification(enabled: enabled);
  }
}

