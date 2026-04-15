import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:khatorgame/core/router/app_router.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:khatorgame/core/network/api_client.dart';
import 'package:khatorgame/core/network/api_client_impl.dart';
import 'package:khatorgame/features/chatbot/data/datasources/chatbot_remote_data_source.dart';
import 'package:khatorgame/features/chatbot/data/repositories/chatbot_repository_impl.dart';
import 'package:khatorgame/features/chatbot/domain/repositories/chatbot_repository.dart';
import 'package:khatorgame/features/chatbot/domain/usecases/chatbot_usecase.dart';
import 'package:khatorgame/features/chatbot/presentation/controllers/chatbot_controller.dart';

void main() async {
  // Baris ini wajib ditambah kalau kita melakukan inisialisasi sebelum runApp
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  // Panggil fungsi inisialisasi dependency kita
  setupDependencies();

  runApp(const MyApp());
}

// Fungsi khusus untuk mendaftarkan semua layer Clean Architecture ke dalam memori
void setupDependencies() {
  // 1. Inisialisasi Core Network (Inject Dio ke dalam ApiClientImpl)
  Get.lazyPut<ApiClient>(() => ApiClientImpl(Dio()));

  // 2. Inisialisasi Fitur Chatbot (Sesuai urutan Clean Architecture)
  Get.lazyPut<ChatbotRemoteDataSource>(() => ChatbotRemoteDataSourceImpl(Get.find<ApiClient>()));
  Get.lazyPut<ChatbotRepository>(() => ChatbotRepositoryImpl(Get.find<ChatbotRemoteDataSource>()));
  Get.lazyPut(() => ChatbotUsecase(Get.find<ChatbotRepository>()));
  Get.lazyPut(() => ChatbotController(Get.find<ChatbotUsecase>()));
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
