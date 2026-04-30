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
          textResponse as String? ?? 'Maaf, AI belum bisa menanggapi saat ini.'
        );
        
      } catch (e) {
        String errorMessage = 'Terjadi kesalahan tidak terduga saat menghubungi AI: $e';
        final errorStr = e.toString().toLowerCase();
        
        if (errorStr.contains('503')) {
          if (retries < maxRetries - 1) {
            retries++;
            // Tunggu beberapa detik (Exponential backoff) sebelum mencoba lagi
            await Future.delayed(Duration(seconds: retries * 2));
            continue; // Ulangi loop
          }
          errorMessage = 'Server AI dari pusat sedang penuh/sibuk (Error 503). Coba lagi nanti.';
        } else if (errorStr.contains('400')) {
          errorMessage = 'Permintaan tidak valid (Error 400). Mohon periksa kembali pesan Anda.';
        } else if (errorStr.contains('401') || errorStr.contains('403')) {
          errorMessage = 'Ada masalah pada API Key Gemini (Akses Ditolak).';
        } else if (errorStr.contains('429')) {
          errorMessage = 'Batas penggunaan AI sudah habis sementara (Error 429). Mohon tunggu sebentar ya.';
        } else if (errorStr.contains('socketexception') || errorStr.contains('connection timeout') || errorStr.contains('network is unreachable')) {
          errorMessage = 'Koneksi internet bermasalah. Pastikan jaringan kamu stabil ya.';
        }

        throw Exception(errorMessage);
      }
    }
    
    throw Exception("Failed to contact server after $maxRetries attempts.");
  }
}