import 'package:get/get.dart';
import '../../domain/entities/chatbot_entity.dart';
import '../../domain/usecases/chatbot_usecase.dart';

class ChatbotController extends GetxController {
  final ChatbotUsecase usecase;

  ChatbotController(this.usecase);

  var messages = <ChatbotEntity>[].obs;
  var isLoading = false.obs;

  Future<void> sendMessage(String prompt) async {
    if (prompt.trim().isEmpty) return;

    messages.add(ChatbotEntity(text: prompt, isUser: true));
    isLoading.value = true;

    try {
      final response = await usecase.execute(prompt);
      
      messages.add(response);
    } catch (e) {
      messages.add(ChatbotEntity(
        text: "Waduh, koneksi ke Gemini lagi bermasalah nih", 
        isUser: false,
      ));
    } finally {
      isLoading.value = false;
    }
  }
}