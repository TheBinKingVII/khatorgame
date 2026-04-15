import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:khatorgame/core/network/api_client.dart';
import 'package:khatorgame/core/network/api_client_impl.dart';
import 'package:khatorgame/core/router/app_router.dart';
import 'package:khatorgame/core/services/session_service.dart';
import 'package:khatorgame/features/chatbot/data/datasources/chatbot_remote_data_source.dart';
import 'package:khatorgame/features/chatbot/data/repositories/chatbot_repository_impl.dart';
import 'package:khatorgame/features/chatbot/domain/repositories/chatbot_repository.dart';
import 'package:khatorgame/features/chatbot/domain/usecases/chatbot_usecase.dart';
import 'package:khatorgame/features/chatbot/presentation/controllers/chatbot_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );
  await SessionService.instance.init();

  setupDependencies();
  
  runApp(const MyApp());
}

// Fungsi khusus untuk mendaftarkan semua layer Clean Architecture ke dalam memori
void setupDependencies() {
  // 1. Inisialisasi Core Network 
  // Gunakan Get.put dan buang kurung panah ()=> 
  Get.put<ApiClient>(ApiClientImpl(Dio()));

  // 2. Inisialisasi Fitur Chatbot 
  Get.put<ChatbotRemoteDataSource>(ChatbotRemoteDataSourceImpl(Get.find<ApiClient>()));
  Get.put<ChatbotRepository>(ChatbotRepositoryImpl(Get.find<ChatbotRemoteDataSource>()));
  Get.put(ChatbotUsecase(Get.find<ChatbotRepository>()));
  
  // Controller langsung dihidupkan dan dikunci ke memori
  Get.put(ChatbotController(Get.find<ChatbotUsecase>()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Khator Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: AppRouter.router,
    );
  }
}
