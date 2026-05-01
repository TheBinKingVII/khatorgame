import 'package:get/get.dart';
import 'package:khatorgame/features/auth/domain/repositories/auth_repository.dart';

class AuthController extends GetxController {
  AuthController(this._authRepository);

  final AuthRepository _authRepository;

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
    canUseBiometricLogin.value = await _authRepository.canShowBiometricLogin();
  }

  Future<void> login({required String email, required String password}) async {
    isLoginLoading.value = true;
    try {
      await _authRepository.login(email: email.trim(), password: password);
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
      await _authRepository.register(
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
      await _authRepository.loginWithBiometric();
      await refreshBiometricAvailability();
    } finally {
      isBiometricLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    await refreshBiometricAvailability();
  }
}
