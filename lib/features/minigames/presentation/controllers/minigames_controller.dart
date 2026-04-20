import 'package:get/get.dart';
import 'package:khatorgame/core/services/session_service.dart';
import '../../domain/usecases/minigames_usecase.dart';

class MinigamesController extends GetxController {
  final MinigamesUsecase usecase;

  MinigamesController(this.usecase);

  final RxBool isLoading = false.obs;
  final RxBool isClaiming = false.obs;
  final RxBool hasClaimedToday = false.obs;
  final RxList<String> collectedVouchers = <String>[].obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadGameData();
  }

  Future<void> loadGameData() async {
    isLoading.value = true;
    try {
      hasClaimedToday.value = await usecase.hasClaimedToday();
      collectedVouchers.value = await usecase.getCollectedVouchers();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Mengembalikan kode voucher kalau sukses, null kalau gagal
  Future<String?> claimVoucher() async {
    isClaiming.value = true;
    errorMessage.value = '';
    
    try {
      final String? currentUserId = SessionService.instance.userId;
      if (currentUserId == null || currentUserId.isEmpty) {
        throw "User tidak terdeteksi (Login dulu gih)";
      }

      final String voucherCode = await usecase.claimVoucher(currentUserId);
      
      // Update UI langsung secara reaktif
      hasClaimedToday.value = true;
      collectedVouchers.add(voucherCode);

      return voucherCode;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      isClaiming.value = false;
    }
  }

  // Buat tombol ngetest
  Future<void> resetTestingData() async {
    await usecase.resetData();
    await loadGameData();
  }
}
