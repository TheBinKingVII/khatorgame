import '../models/chatbot_model.dart';
import '../../../../core/network/api_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class ChatbotRemoteDataSource {
  Future<ChatbotModel> getGeminiResponse(String prompt);
}

class ChatbotRemoteDataSourceImpl implements ChatbotRemoteDataSource {
  final ApiClient apiClient;
  final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? ''; 

  ChatbotRemoteDataSourceImpl(this.apiClient);

  @override
  Future<ChatbotModel> getGeminiResponse(String prompt) async {
    if (apiKey.isEmpty) {
      throw Exception('API Key kosong!');
    }

    try {
      final path = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey';
      
      final response = await apiClient.post(
        path,
        headers: {
          'Content-Type': 'application/json',
        },
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

      final textResponse = response['candidates'][0]['content']['parts'][0]['text'];
      
      return ChatbotModel.fromGeminiResponse(
        textResponse as String? ?? 'Maaf, AI belum bisa menanggapi saat ini.'
      );
      
    } catch (e) {
      throw Exception('Terjadi kesalahan saat memanggil Gemini API: $e');
    }
  }
}