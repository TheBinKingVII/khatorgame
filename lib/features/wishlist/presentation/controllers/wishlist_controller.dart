import 'package:get/get.dart';
import 'package:khatorgame/features/wishlist/domain/entities/wishlist_entity.dart';
import 'package:khatorgame/features/wishlist/domain/usecases/wishlist_usecase.dart';

class WishlistController extends GetxController {
  WishlistController(this._usecase);

  final WishlistUsecase _usecase;

  final RxList<WishlistItemEntity> items = <WishlistItemEntity>[].obs;
  final RxBool syncBusy = false.obs;

  @override
  void onInit() {
    super.onInit();
    refreshFromLocal();
  }

  Future<void> refreshFromLocal() async {
    items.assignAll(await _usecase.getLocalItems());
  }

  Future<void> syncFromRemote() async {
    syncBusy.value = true;
    try {
      await _usecase.syncFromRemote();
      await refreshFromLocal();
    } finally {
      syncBusy.value = false;
    }
  }

  Future<void> toggle({
    required String dealId,
    required String title,
    required String price,
    required String imageUrl,
  }) async {
    if (items.any((WishlistItemEntity e) => e.dealId == dealId)) {
      await _usecase.removeItem(dealId);
    } else {
      await _usecase.addItem(
        dealId: dealId,
        title: title,
        price: price,
        imageUrl: imageUrl,
      );
    }
    await refreshFromLocal();
  }

  Future<void> remove(String dealId) async {
    await _usecase.removeItem(dealId);
    await refreshFromLocal();
  }

  void clearState() {
    items.clear();
  }
}
