import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:khatorgame/core/errors/app_error_mapper.dart';
import 'package:khatorgame/core/services/biometric_auth_service.dart';
import 'package:khatorgame/core/services/wishlist_reminder_notification_service.dart';
import 'package:khatorgame/features/profile/domain/entities/currency_option_entity.dart';
import 'package:khatorgame/features/profile/domain/entities/profile_entity.dart';
import 'package:khatorgame/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:khatorgame/features/profile/domain/usecases/update_currency_usecase.dart';
import 'package:khatorgame/features/profile/domain/usecases/update_notification_usecase.dart';
import 'package:khatorgame/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:khatorgame/features/profile/domain/usecases/upload_avatar_usecase.dart';

class ProfileController extends GetxController {
  ProfileController({
    required GetProfileUsecase getProfileUsecase,
    required UpdateProfileUsecase updateProfileUsecase,
    required UpdateCurrencyUsecase updateCurrencyUsecase,
    required UpdateNotificationUsecase updateNotificationUsecase,
    required UploadAvatarUsecase uploadAvatarUsecase,
    required WishlistReminderNotificationService wishlistReminderService,
    ImagePicker? imagePicker,
  }) : _getProfileUsecase = getProfileUsecase,
       _updateProfileUsecase = updateProfileUsecase,
       _updateCurrencyUsecase = updateCurrencyUsecase,
       _updateNotificationUsecase = updateNotificationUsecase,
       _uploadAvatarUsecase = uploadAvatarUsecase,
       _wishlistReminderService = wishlistReminderService,
       _imagePicker = imagePicker ?? ImagePicker();

  final GetProfileUsecase _getProfileUsecase;
  final UpdateProfileUsecase _updateProfileUsecase;
  final UpdateCurrencyUsecase _updateCurrencyUsecase;
  final UpdateNotificationUsecase _updateNotificationUsecase;
  final UploadAvatarUsecase _uploadAvatarUsecase;
  final WishlistReminderNotificationService _wishlistReminderService;
  final ImagePicker _imagePicker;
  final BiometricAuthService _biometricService = BiometricAuthService.instance;

  final Rxn<ProfileEntity> profile = Rxn<ProfileEntity>();
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxBool isBiometricEnabled = false.obs;
  final RxnString biometricStatusMessage = RxnString();
  final RxnString errorMessage = RxnString();
  final RxnString pendingAvatarPath = RxnString();

  final List<CurrencyOptionEntity> currencies = const <CurrencyOptionEntity>[
    CurrencyOptionEntity(code: 'USD', label: 'US Dollar', symbol: '\$'),
    CurrencyOptionEntity(code: 'IDR', label: 'Indonesian Rupiah', symbol: 'Rp'),
    CurrencyOptionEntity(code: 'EUR', label: 'Euro', symbol: '€'),
    CurrencyOptionEntity(code: 'JPY', label: 'Japanese Yen', symbol: '¥'),
  ];

  @override
  void onInit() {
    super.onInit();
    _loadBiometricStatus();
    loadProfile();
  }

  Future<void> _loadBiometricStatus() async {
    isBiometricEnabled.value = await _biometricService.isBiometricEnabled();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      profile.value = await _getProfileUsecase();
      await _wishlistReminderService.updateNotificationsEnabled(
        profile.value?.notificationsEnabled ?? false,
      );
    } catch (error) {
      errorMessage.value = mapErrorToUserMessage(
        error,
        fallbackMessage: 'Gagal memuat profil. Coba lagi.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveFullName(String fullName) async {
    isSaving.value = true;
    try {
      profile.value = await _updateProfileUsecase(fullName: fullName.trim());
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> saveCurrency(String currencyCode) async {
    isSaving.value = true;
    try {
      profile.value = await _updateCurrencyUsecase(currencyCode: currencyCode);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> saveNotification(bool enabled) async {
    isSaving.value = true;
    try {
      profile.value = await _updateNotificationUsecase(enabled: enabled);
      await _wishlistReminderService.updateNotificationsEnabled(
        profile.value?.notificationsEnabled ?? enabled,
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> setBiometricEnabled(bool enabled) async {
    biometricStatusMessage.value = null;
    if (enabled) {
      final ProfileEntity? currentProfile = profile.value;
      if (currentProfile == null) {
        biometricStatusMessage.value =
            'Profil belum siap. Coba lagi setelah data profil termuat.';
        return false;
      }
      final bool canUseBiometric = await _biometricService.canUseBiometric();
      if (!canUseBiometric) {
        biometricStatusMessage.value =
            'Perangkat tidak mendukung biometrik atau belum dikonfigurasi.';
        return false;
      }
      final bool saved = await _biometricService.enableForUser(
        userId: currentProfile.id,
        userEmail: currentProfile.email,
      );
      if (!saved) {
        biometricStatusMessage.value =
            'Aktivasi dibatalkan atau verifikasi biometrik gagal.';
      }
      isBiometricEnabled.value = saved;
      return saved;
    }
    await _biometricService.disable();
    isBiometricEnabled.value = false;
    biometricStatusMessage.value = 'Biometrik dinonaktifkan.';
    return true;
  }

  Future<bool> pickAvatarPath() async {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      imageQuality: 85,
    );
    if (pickedFile == null) {
      return false;
    }
    pendingAvatarPath.value = pickedFile.path;
    return true;
  }

  Future<bool> uploadAvatar(String filePath) async {
    isSaving.value = true;
    try {
      profile.value = await _uploadAvatarUsecase(filePath: filePath);
      return true;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> uploadPendingAvatar() async {
    final String? pendingPath = pendingAvatarPath.value;
    if (pendingPath == null || pendingPath.isEmpty) {
      return false;
    }
    final bool changed = await uploadAvatar(pendingPath);
    if (changed) {
      pendingAvatarPath.value = null;
    }
    return changed;
  }

  void clearState() {
    profile.value = null;
    errorMessage.value = null;
    isLoading.value = false;
    isSaving.value = false;
    pendingAvatarPath.value = null;
    _wishlistReminderService.updateNotificationsEnabled(false);
  }
}
