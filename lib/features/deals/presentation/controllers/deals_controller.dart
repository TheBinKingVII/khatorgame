import 'package:get/get.dart';
import 'package:khatorgame/features/deals/data/repositories/deals_repository_impl.dart';
import 'package:khatorgame/features/deals/domain/entities/deals_entity.dart';
import 'package:khatorgame/features/deals/domain/usecases/deals_usecase.dart';

class DealsController extends GetxController {
  DealsController({DealsUsecase? usecase})
      : _usecase = usecase ?? DealsUsecase(DealsRepositoryImpl());

  final DealsUsecase _usecase;
  final RxList<DealsEntity> deals = <DealsEntity>[].obs;
  final RxBool isInitialLoading = true.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxnString errorMessage = RxnString();

  int _currentPage = 0;

  Future<void> loadInitialDeals() async {
    isInitialLoading.value = true;
    errorMessage.value = null;
    _currentPage = 0;
    hasMore.value = true;
    deals.clear();

    try {
      final List<DealsEntity> firstPage = await _usecase.getDeals(pageNumber: 0);
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
      final List<DealsEntity> nextDeals =
          await _usecase.getDeals(pageNumber: nextPage);
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
}
