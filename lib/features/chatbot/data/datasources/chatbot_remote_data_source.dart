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
      throw Exception('API Key is missing!');
    }

    int retries = 0;
    const maxRetries = 3;

    while (retries < maxRetries) {
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
          textResponse as String? ?? 'Sorry, AI is unable to respond at this time.'
        );
        
      } catch (e) {
        String errorMessage = 'Terjadi kesalahan tidak terduga saat menghubungi AI: $e';
        final errorStr = e.toString().toLowerCase();
        
        if (errorStr.contains('503')) {
          if (retries < maxRetries - 1) {
            retries++;
            // Wait for exponential backoff
            await Future.delayed(Duration(seconds: retries * 2));
            continue; 
          }
          errorMessage = 'AI Server is currently busy (Error 503). Please try again later.';
        } else if (errorStr.contains('400')) {
          errorMessage = 'Invalid request (Error 400). Please check your message.';
        } else if (errorStr.contains('401') || errorStr.contains('403')) {
          errorMessage = 'Gemini API Key issue (Access Denied).';
        } else if (errorStr.contains('429')) {
          errorMessage = 'AI usage limit reached (Error 429). Please wait a moment.';
        } else if (errorStr.contains('socketexception') || errorStr.contains('connection timeout') || errorStr.contains('network is unreachable')) {
          errorMessage = 'Network problem. Please ensure your connection is stable.';
        }

        throw Exception(errorMessage);
      }
    }
    
    throw Exception("Failed to contact server after $maxRetries attempts.");
  }
}