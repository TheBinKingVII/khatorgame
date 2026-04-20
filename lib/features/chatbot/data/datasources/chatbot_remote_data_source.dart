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
      String errorMessage = 'Terjadi kesalahan tidak terduga saat menghubungi AI: $e';
      final errorStr = e.toString().toLowerCase();
      
      if (errorStr.contains('503')) {
        errorMessage = 'Server AI saat ini sedang penuh/sibuk (Error 503). Silakan coba lagi beberapa saat.';
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
}