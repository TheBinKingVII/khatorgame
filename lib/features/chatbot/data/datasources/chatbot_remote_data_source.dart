import '../models/chatbot_model.dart';
import '../../../../core/network/api_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class ChatbotRemoteDataSource {
  Future<ChatbotModel> getGeminiResponse(String prompt);
}

class ChatbotRemoteDataSourceImpl implements ChatbotRemoteDataSource {
  // 1. Ganti Dio menjadi ApiClient buatan temanmu
  final ApiClient apiClient;
  
  // TODO: Nanti ganti dengan pemanggilan dari file .env milikmu
  final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? ''; 

  // 2. Inject ApiClient melalui constructor
  ChatbotRemoteDataSourceImpl(this.apiClient);

  @override
  Future<ChatbotModel> getGeminiResponse(String prompt) async {
    try {
      final path = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey';
      
      // 3. Gunakan method post dari ApiClient
      // Perhatikan parameter 'body' sesuai dengan kontrak di ApiClient
      final response = await apiClient.post(
        path,
        body: {
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ]
        },
      );

      // 4. Asumsi: method post di ApiClient buatan temanmu me-return 
      // data yang sudah berupa Map/JSON (response.data dari Dio).
      // Jadi kita bisa langsung mengakses key-nya.
      final textResponse = response['candidates'][0]['content']['parts'][0]['text'];
      
      return ChatbotModel.fromGeminiResponse(
        textResponse as String? ?? 'Maaf, AI belum bisa menanggapi saat ini.'
      );
      
    } catch (e) {
      // 5. Karena kita pakai ApiClient (abstraksi), kita catch exception umum dulu.
      // Temanmu mungkin punya mekanisme custom error di ApiClient-nya.
      throw Exception('Terjadi kesalahan saat memanggil Gemini API: $e');
    }
  }
}