import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:khatorgame/core/network/api_client.dart';
import 'package:khatorgame/core/network/api_client_impl.dart';
import 'package:khatorgame/core/router/app_router.dart';
import 'package:khatorgame/core/services/local_storage.dart';
import 'package:khatorgame/core/services/session_service.dart';
import 'package:khatorgame/core/services/wishlist_reminder_notification_service.dart';
import 'package:khatorgame/features/chatbot/data/datasources/chatbot_remote_data_source.dart';
import 'package:khatorgame/features/chatbot/data/repositories/chatbot_repository_impl.dart';
import 'package:khatorgame/features/chatbot/domain/repositories/chatbot_repository.dart';
import 'package:khatorgame/features/chatbot/domain/usecases/chatbot_usecase.dart';
import 'package:khatorgame/features/chatbot/presentation/controllers/chatbot_controller.dart';
import 'package:khatorgame/features/deals/data/datasources/deals_remote_data_source.dart';
import 'package:khatorgame/features/deals/data/repositories/deals_repository_impl.dart';
import 'package:khatorgame/features/deals/domain/repositories/deals_repository.dart';
import 'package:khatorgame/features/deals/domain/usecases/deals_usecase.dart';
import 'package:khatorgame/features/deals/presentation/controllers/deals_controller.dart';
import 'package:khatorgame/features/internetcafe/data/datasources/internetcafe_device_data_source.dart';
import 'package:khatorgame/features/internetcafe/data/datasources/internetcafe_remote_data_source.dart';
import 'package:khatorgame/features/internetcafe/data/repositories/internetcafe_repository_impl.dart';
import 'package:khatorgame/features/internetcafe/domain/repositories/internetcafe_repository.dart';
import 'package:khatorgame/features/internetcafe/domain/usecases/internetcafe_usecase.dart';
import 'package:khatorgame/features/internetcafe/presentation/controllers/internetcafe_controller.dart';
import 'package:khatorgame/features/minigames/data/datasources/minigames_local_data_source.dart';
import 'package:khatorgame/features/minigames/data/datasources/minigames_remote_data_source.dart';
import 'package:khatorgame/features/minigames/data/repositories/minigames_repository_impl.dart';
import 'package:khatorgame/features/minigames/domain/repositories/minigames_repository.dart';
import 'package:khatorgame/features/minigames/domain/usecases/minigames_usecase.dart';
import 'package:khatorgame/features/minigames/presentation/controllers/minigames_controller.dart';
import 'package:khatorgame/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:khatorgame/features/auth/domain/repositories/auth_repository.dart';
import 'package:khatorgame/features/auth/domain/usecases/auth_usecase.dart';
import 'package:khatorgame/features/auth/presentation/controllers/auth_controller.dart';
import 'package:khatorgame/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:khatorgame/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:khatorgame/features/profile/domain/repositories/profile_repository.dart';
import 'package:khatorgame/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:khatorgame/features/profile/domain/usecases/update_currency_usecase.dart';
import 'package:khatorgame/features/profile/domain/usecases/update_notification_usecase.dart';
import 'package:khatorgame/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:khatorgame/features/profile/domain/usecases/upload_avatar_usecase.dart';
import 'package:khatorgame/features/profile/presentation/controllers/profile_controller.dart';
import 'package:khatorgame/features/wishlist/data/datasources/wishlist_local_data_source.dart';
import 'package:khatorgame/features/wishlist/data/datasources/wishlist_remote_data_source.dart';
import 'package:khatorgame/features/wishlist/data/repositories/wishlist_repository_impl.dart';
import 'package:khatorgame/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:khatorgame/features/wishlist/domain/usecases/wishlist_usecase.dart';
import 'package:khatorgame/features/wishlist/presentation/controllers/wishlist_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:khatorgame/core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await dotenv.load(fileName: '.env');
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );
  await SessionService.instance.init();
  await LocalStorageService.instance.init();

  setupDependencies();
  await Get.find<WishlistReminderNotificationService>().initialize();

  if (SessionService.instance.hasValidSession) {
    try {
      await Get.find<WishlistRepository>().syncFromRemote();
      await Get.find<WishlistController>().refreshFromLocal();
    } catch (error, stackTrace) {
      debugPrint('Wishlist sync at startup: $error\n$stackTrace');
    }
  }

  runApp(const MyApp());
}

// Fungsi khusus untuk mendaftarkan semua layer Clean Architecture ke dalam memori
void setupDependencies() {
  // 1. Inisialisasi Core Network
  // Gunakan Get.put dan buang kurung panah ()=>
  Get.put<ApiClient>(ApiClientImpl(Dio()));
  Get.put<WishlistReminderNotificationService>(
    WishlistReminderNotificationService(),
    permanent: true,
  );

  // 2. Inisialisasi Fitur Chatbot
  Get.put<ChatbotRemoteDataSource>(
    ChatbotRemoteDataSourceImpl(Get.find<ApiClient>()),
  );
  Get.put<ChatbotRepository>(
    ChatbotRepositoryImpl(Get.find<ChatbotRemoteDataSource>()),
  );
  Get.put(ChatbotUsecase(Get.find<ChatbotRepository>()));

  // Controller langsung dihidupkan dan dikunci ke memori
  Get.put(ChatbotController(Get.find<ChatbotUsecase>()));

  // 3. Wishlist (Supabase + SQLite cache)
  Get.put<WishlistRemoteDataSource>(WishlistRemoteDataSourceImpl());
  Get.put<WishlistLocalDataSource>(WishlistLocalDataSource());
  Get.put<WishlistRepository>(
    WishlistRepositoryImpl(
      remoteDataSource: Get.find<WishlistRemoteDataSource>(),
      localDataSource: Get.find<WishlistLocalDataSource>(),
    ),
  );
  Get.put<WishlistUsecase>(WishlistUsecase(Get.find<WishlistRepository>()));
  Get.put<WishlistController>(
    WishlistController(
      Get.find<WishlistUsecase>(),
      Get.find<WishlistReminderNotificationService>(),
    ),
    permanent: true,
  );

  // 4. Auth
  Get.put<AuthRepository>(AuthRepositoryImpl(), permanent: true);
  Get.put<AuthUsecase>(
    AuthUsecase(Get.find<AuthRepository>()),
    permanent: true,
  );
  Get.put<AuthController>(
    AuthController(Get.find<AuthUsecase>()),
    permanent: true,
  );

  // 5. Deals
  Get.put<DealsRemoteDataSource>(DealsRemoteDataSource(), permanent: true);
  Get.put<DealsRepository>(
    DealsRepositoryImpl(remoteDataSource: Get.find<DealsRemoteDataSource>()),
    permanent: true,
  );
  Get.put<DealsUsecase>(
    DealsUsecase(Get.find<DealsRepository>()),
    permanent: true,
  );
  Get.put<DealsController>(
    DealsController(usecase: Get.find<DealsUsecase>()),
    permanent: true,
  );

  // 6. Profile
  Get.put<ProfileRemoteDataSource>(ProfileRemoteDataSourceImpl());
  Get.put<ProfileRepository>(
    ProfileRepositoryImpl(
      remoteDataSource: Get.find<ProfileRemoteDataSource>(),
    ),
  );
  Get.put<GetProfileUsecase>(GetProfileUsecase(Get.find<ProfileRepository>()));
  Get.put<UpdateProfileUsecase>(
    UpdateProfileUsecase(Get.find<ProfileRepository>()),
  );
  Get.put<UpdateCurrencyUsecase>(
    UpdateCurrencyUsecase(Get.find<ProfileRepository>()),
  );
  Get.put<UpdateNotificationUsecase>(
    UpdateNotificationUsecase(Get.find<ProfileRepository>()),
  );
  Get.put<UploadAvatarUsecase>(
    UploadAvatarUsecase(Get.find<ProfileRepository>()),
  );
  Get.put<ProfileController>(
    ProfileController(
      getProfileUsecase: Get.find<GetProfileUsecase>(),
      updateProfileUsecase: Get.find<UpdateProfileUsecase>(),
      updateCurrencyUsecase: Get.find<UpdateCurrencyUsecase>(),
      updateNotificationUsecase: Get.find<UpdateNotificationUsecase>(),
      uploadAvatarUsecase: Get.find<UploadAvatarUsecase>(),
      wishlistReminderService: Get.find<WishlistReminderNotificationService>(),
    ),
    permanent: true,
  );

  // 7. Minigames
  Get.put<MinigamesRemoteDataSource>(MinigamesRemoteDataSourceImpl());
  Get.put<MinigamesLocalDataSource>(MinigamesLocalDataSourceImpl());
  Get.put<MinigamesRepository>(
    MinigamesRepositoryImpl(
      remoteDataSource: Get.find<MinigamesRemoteDataSource>(),
      localDataSource: Get.find<MinigamesLocalDataSource>(),
    ),
  );
  Get.put<MinigamesUsecase>(MinigamesUsecase(Get.find<MinigamesRepository>()));
  Get.put<MinigamesController>(
    MinigamesController(Get.find<MinigamesUsecase>()),
    permanent: true,
  );

  // 8. Internetcafe — pakai lazyPut agar controller baru hidup saat halamannya dibuka,
  // sehingga dialog izin lokasi muncul di saat yang tepat (bukan saat login).
  Get.lazyPut<InternetcafeDeviceDataSource>(
    () => InternetcafeDeviceDataSourceImpl(),
  );
  Get.lazyPut<InternetcafeRemoteDataSource>(
    () => InternetcafeRemoteDataSourceImpl(),
  );
  Get.lazyPut<InternetcafeRepository>(
    () => InternetcafeRepositoryImpl(
      deviceDataSource: Get.find<InternetcafeDeviceDataSource>(),
      remoteDataSource: Get.find<InternetcafeRemoteDataSource>(),
    ),
  );
  Get.lazyPut<InternetcafeUsecase>(
    () => InternetcafeUsecase(Get.find<InternetcafeRepository>()),
  );
  Get.lazyPut<InternetcafeController>(
    () => InternetcafeController(Get.find<InternetcafeUsecase>()),
    fenix: true, // Dibuat ulang kalau user keluar lalu masuk lagi ke halaman
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Khator Game',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light, // Default light mode
      routerConfig: AppRouter.router,
    );
  }
}
