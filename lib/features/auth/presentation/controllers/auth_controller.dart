import 'package:get/get.dart';
import 'package:khatorgame/features/auth/domain/usecases/auth_usecase.dart';

class AuthController extends GetxController {
  AuthController(this._authUsecase);

  final AuthUsecase _authUsecase;

  final RxBool isLoginLoading = false.obs;
  final RxBool isRegisterLoading = false.obs;
  final RxBool isBiometricLoading = false.obs;
  final RxBool canUseBiometricLogin = false.obs;

  @override
  void onInit() {
    super.onInit();
    refreshBiometricAvailability();
  }

  Future<void> refreshBiometricAvailability() async {
    canUseBiometricLogin.value = await _authUsecase.canShowBiometricLogin();
  }

  Future<void> login({required String email, required String password}) async {
    isLoginLoading.value = true;
    try {
      await _authUsecase.login(email: email.trim(), password: password);
      await refreshBiometricAvailability();
    } finally {
      isLoginLoading.value = false;
    }
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    isRegisterLoading.value = true;
    try {
      await _authUsecase.register(
        fullName: fullName.trim(),
        email: email.trim(),
        password: password,
      );
    } finally {
      isRegisterLoading.value = false;
    }
  }

  Future<void> loginWithBiometric() async {
    isBiometricLoading.value = true;
    try {
      await _authUsecase.loginWithBiometric();
      await refreshBiometricAvailability();
    } finally {
      isBiometricLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _authUsecase.logout();
    await refreshBiometricAvailability();
  }
}
