import 'package:get/get.dart';
import 'package:khatorgame/features/deals/data/repositories/deals_repository_impl.dart';
import 'package:khatorgame/features/deals/domain/entities/deals_entity.dart';
import 'package:khatorgame/features/deals/domain/usecases/deals_usecase.dart';

class DealsController extends GetxController {
  DealsController({DealsUsecase? usecase})
    : _usecase = usecase ?? DealsUsecase(DealsRepositoryImpl());

  final DealsUsecase _usecase;
  final RxList<DealsEntity> deals = <DealsEntity>[].obs;
  final RxList<StoreEntity> stores = <StoreEntity>[].obs;
  final RxBool isInitialLoading = true.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxnString errorMessage = RxnString();
  final RxnInt selectedStoreId = RxnInt();

  int _currentPage = 0;

  Future<void> initialize() async {
    await _loadActiveStores();
    await loadInitialDeals();
  }

  Future<void> _loadActiveStores() async {
    try {
      final List<StoreEntity> activeStores = await _usecase.getActiveStores();
      stores
        ..clear()
        ..addAll(activeStores);
    } catch (_) {
      stores.clear();
    }
  }

  Future<void> loadInitialDeals() async {
    isInitialLoading.value = true;
    errorMessage.value = null;
    _currentPage = 0;
    hasMore.value = true;
    deals.clear();

    try {
      final List<DealsEntity> firstPage = await _usecase.getDeals(
        pageNumber: 0,
        storeId: selectedStoreId.value,
      );
      deals.addAll(firstPage);
      hasMore.value = firstPage.isNotEmpty;
    } catch (error) {
      errorMessage.value = error.toString();
    } finally {
      isInitialLoading.value = false;
    }
  }

  Future<void> loadMoreDeals() async {
    if (isLoadingMore.value || !hasMore.value) return;

    isLoadingMore.value = true;

    try {
      final int nextPage = _currentPage + 1;
      final List<DealsEntity> nextDeals = await _usecase.getDeals(
        pageNumber: nextPage,
        storeId: selectedStoreId.value,
      );
      _currentPage = nextPage;
      deals.addAll(nextDeals);
      hasMore.value = nextDeals.isNotEmpty;
    } catch (_) {
      // Keep silent on pagination errors; users can retry by scrolling.
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<DealsDetailEntity> getDealDetail(String dealId) {
    return _usecase.getDealDetail(dealId);
  }

  Future<void> changeStoreFilter(int? storeId) async {
    if (selectedStoreId.value == storeId) return;
    selectedStoreId.value = storeId;
    await loadInitialDeals();
  }
}
