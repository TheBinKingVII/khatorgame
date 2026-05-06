import '../entities/chatbot_entity.dart';

abstract class ChatbotRepository {
  /// Fungsi untuk mengirim prompt ke AI dan mengembalikan balasan berupa ChatbotEntity
  Future<ChatbotEntity> sendMessage(String prompt);
}