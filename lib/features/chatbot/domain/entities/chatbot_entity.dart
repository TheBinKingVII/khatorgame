class ChatbotEntity {
  final String text;
  final bool isUser; // true jika pesan dari user, false jika balasan dari Gemini

  ChatbotEntity({
    required this.text,
    required this.isUser,
  });
}