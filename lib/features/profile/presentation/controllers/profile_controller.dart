import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
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
    ImagePicker? imagePicker,
  })  : _getProfileUsecase = getProfileUsecase,
        _updateProfileUsecase = updateProfileUsecase,
        _updateCurrencyUsecase = updateCurrencyUsecase,
        _updateNotificationUsecase = updateNotificationUsecase,
        _uploadAvatarUsecase = uploadAvatarUsecase,
        _imagePicker = imagePicker ?? ImagePicker();

  final GetProfileUsecase _getProfileUsecase;
  final UpdateProfileUsecase _updateProfileUsecase;
  final UpdateCurrencyUsecase _updateCurrencyUsecase;
  final UpdateNotificationUsecase _updateNotificationUsecase;
  final UploadAvatarUsecase _uploadAvatarUsecase;
  final ImagePicker _imagePicker;

  final Rxn<ProfileEntity> profile = Rxn<ProfileEntity>();
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxnString errorMessage = RxnString();

  final List<CurrencyOptionEntity> currencies = const <CurrencyOptionEntity>[
    CurrencyOptionEntity(code: 'USD', label: 'US Dollar', symbol: '\$'),
    CurrencyOptionEntity(code: 'IDR', label: 'Indonesian Rupiah', symbol: 'Rp'),
    CurrencyOptionEntity(code: 'EUR', label: 'Euro', symbol: '€'),
    CurrencyOptionEntity(code: 'JPY', label: 'Japanese Yen', symbol: '¥'),
  ];

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      profile.value = await _getProfileUsecase();
    } catch (error) {
      errorMessage.value = error.toString();
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
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> pickAndUploadAvatar() async {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      imageQuality: 85,
    );
    if (pickedFile == null) return false;

    isSaving.value = true;
    try {
      profile.value = await _uploadAvatarUsecase(filePath: pickedFile.path);
      return true;
    } finally {
      isSaving.value = false;
    }
  }

  void clearState() {
    profile.value = null;
    errorMessage.value = null;
    isLoading.value = false;
    isSaving.value = false;
  }
}

