import '../../domain/entities/chatbot_entity.dart';

class ChatbotModel extends ChatbotEntity {
  ChatbotModel({
    required super.text,
    required super.isUser,
  });

  // Factory untuk memetakan balasan teks dari Gemini menjadi objek ChatbotModel
  factory ChatbotModel.fromGeminiResponse(String textResponse) {
    return ChatbotModel(
      text: textResponse,
      isUser: false, // Selalu false karena ini balasan dari AI
    );
  }
}