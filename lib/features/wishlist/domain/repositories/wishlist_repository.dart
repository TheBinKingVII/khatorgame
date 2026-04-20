import '../entities/wishlist_entity.dart';

abstract class WishlistRepository {
  Future<void> syncFromRemote();

  Future<List<WishlistItemEntity>> getLocalItems();

  Future<bool> isInWishlist(String dealId);

  Future<void> addItem({
    required String dealId,
    required String title,
    required String price,
    required String imageUrl,
  });

  Future<void> removeItem(String dealId);

  Future<void> clearLocalForUser(String userId);
}
