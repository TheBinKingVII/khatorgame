import '../../domain/entities/chatbot_entity.dart';
import '../../domain/repositories/chatbot_repository.dart';
import '../datasources/chatbot_remote_data_source.dart';

class ChatbotRepositoryImpl implements ChatbotRepository {
  final ChatbotRemoteDataSource remoteDataSource;

  ChatbotRepositoryImpl(this.remoteDataSource);

  @override
  Future<ChatbotEntity> sendMessage(String prompt) async {
    try {
      final result = await remoteDataSource.getGeminiResponse(prompt);
      return result; 
    } catch (e) {
      throw Exception('Terjadi kesalahan saat menghubungi AI: $e');
    }
  }
}