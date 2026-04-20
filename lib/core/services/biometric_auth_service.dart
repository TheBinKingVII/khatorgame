import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricIdentity {
  const BiometricIdentity({required this.userId, required this.userEmail});

  final String userId;
  final String userEmail;
}

class BiometricAuthService {
  BiometricAuthService._();

  static final BiometricAuthService instance = BiometricAuthService._();

  static const String _enabledKey = 'biometric_enabled';
  static const String _userIdKey = 'biometric_user_id';
  static const String _userEmailKey = 'biometric_user_email';

  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> canUseBiometric() async {
    final bool isSupported = await _localAuth.isDeviceSupported();
    final bool canCheck = await _localAuth.canCheckBiometrics;
    final List<BiometricType> available = await _localAuth
        .getAvailableBiometrics();
    return isSupported && canCheck && available.isNotEmpty;
  }

  Future<bool> isBiometricEnabled() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? false;
  }

  Future<BiometricIdentity?> getSavedIdentity() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool enabled = prefs.getBool(_enabledKey) ?? false;
    final String? userId = prefs.getString(_userIdKey);
    final String? userEmail = prefs.getString(_userEmailKey);
    if (!enabled || userId == null || userId.isEmpty) {
      return null;
    }
    return BiometricIdentity(userId: userId, userEmail: userEmail ?? '');
  }

  Future<bool> enableForUser({
    required String userId,
    required String userEmail,
  }) async {
    final bool canUse = await canUseBiometric();
    if (!canUse) return false;

    final bool passed = await _localAuth.authenticate(
      localizedReason:
          'Verifikasi biometrik untuk mengaktifkan login biometrik',
      biometricOnly: true,
      persistAcrossBackgrounding: true,
    );
    if (!passed) return false;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, true);
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userEmailKey, userEmail);
    return true;
  }

  Future<bool> authenticateForLogin() async {
    final BiometricIdentity? identity = await getSavedIdentity();
    if (identity == null) return false;
    return _localAuth.authenticate(
      localizedReason: 'Verifikasi biometrik untuk masuk',
      biometricOnly: true,
      persistAcrossBackgrounding: true,
    );
  }

  Future<void> disable() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_enabledKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userEmailKey);
  }
}
