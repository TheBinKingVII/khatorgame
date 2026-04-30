import 'package:get/get.dart';
import 'package:khatorgame/core/errors/app_error_mapper.dart';
import 'package:khatorgame/core/services/session_service.dart';
import '../../domain/usecases/minigames_usecase.dart';

class MinigamesController extends GetxController {
  final MinigamesUsecase usecase;

  MinigamesController(this.usecase);

  final RxBool isLoading = false.obs;
  final RxBool isClaiming = false.obs;
  final RxBool hasClaimedToday = false.obs;
  final RxList<String> collectedVouchers = <String>[].obs;
  final RxBool isVoucherAvailable = true.obs;
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
      isVoucherAvailable.value = await usecase.checkVoucherAvailability();
    } catch (error) {
      errorMessage.value = mapErrorToUserMessage(
        error,
        fallbackMessage: 'Failed to load minigames data. Try again.',
      );
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

      // Klaim voucher dulu — ini yang butuh internet
      final String voucherCode = await usecase.claimVoucher(currentUserId);
      
      // Update state klaim
      hasClaimedToday.value = true;

      // Reload data (best effort — jangan sampai nutupin voucher yang udah berhasil)
      try {
        await loadGameData();
      } catch (_) {
        // Reload gagal tidak masalah, voucher sudah tersimpan
        collectedVouchers.add(voucherCode);
      }

      return voucherCode;
    } catch (error) {
      errorMessage.value = mapErrorToUserMessage(
        error,
        fallbackMessage: 'Failed to claim voucher. Try again.',
      );
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
