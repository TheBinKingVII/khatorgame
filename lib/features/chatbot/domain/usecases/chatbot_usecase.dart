import '../entities/chatbot_entity.dart';
import '../repositories/chatbot_repository.dart';

class ChatbotUsecase {
  final ChatbotRepository repository;

  // Constructor menerima repository sebagai dependency (Dependency Injection)
  ChatbotUsecase(this.repository);

  // Fungsi utama untuk dieksekusi oleh Controller/UI nanti
  Future<ChatbotEntity> execute(String prompt) async {
    // Validasi sederhana bisa ditaruh di sini sebelum nembak ke repository
    if (prompt.trim().isEmpty) {
      throw Exception('Prompt tidak boleh kosong'); 
    }
    
    return await repository.sendMessage(prompt);
  }
}