import '../entities/wishlist_entity.dart';
import '../repositories/wishlist_repository.dart';

class WishlistUsecase {
  WishlistUsecase(this._repository);

  final WishlistRepository _repository;

  Future<void> syncFromRemote() => _repository.syncFromRemote();

  Future<List<WishlistItemEntity>> getLocalItems() =>
      _repository.getLocalItems();

  Future<bool> isInWishlist(String dealId) =>
      _repository.isInWishlist(dealId);

  Future<void> addItem({
    required String dealId,
    required String title,
    required String price,
    required String imageUrl,
  }) {
    return _repository.addItem(
      dealId: dealId,
      title: title,
      price: price,
      imageUrl: imageUrl,
    );
  }

  Future<void> removeItem(String dealId) => _repository.removeItem(dealId);

  Future<void> clearLocalForUser(String userId) =>
      _repository.clearLocalForUser(userId);
}
