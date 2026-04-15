import '../entities/chatbot_entity.dart';
// Catatan: Kalau proyekmu pakai package Either (seperti dartz) dan base_failure.dart
// untuk error handling, return type-nya bisa disesuaikan jadi Future<Either<BaseFailure, ChatbotEntity>>

abstract class ChatbotRepository {
  /// Fungsi untuk mengirim prompt ke AI dan mengembalikan balasan berupa ChatbotEntity
  Future<ChatbotEntity> sendMessage(String prompt);
}