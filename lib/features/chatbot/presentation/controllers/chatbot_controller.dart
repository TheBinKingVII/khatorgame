import 'package:get/get.dart';
import '../../domain/entities/chatbot_entity.dart';
import '../../domain/usecases/chatbot_usecase.dart';

class ChatbotController extends GetxController {
  final ChatbotUsecase usecase;

  ChatbotController(this.usecase);

  // Variabel reactive (.obs)
  var messages = <ChatbotEntity>[].obs;
  var isLoading = false.obs;

  Future<void> sendMessage(String prompt) async {
    if (prompt.trim().isEmpty) return;

    // 1. Tambah pesan user
    messages.add(ChatbotEntity(text: prompt, isUser: true));
    isLoading.value = true;

    try {
      // 2. Panggil Usecase
      final response = await usecase.execute(prompt);
      
      // 3. Tambah balasan AI
      messages.add(response);
    } catch (e) {
      messages.add(ChatbotEntity(
        text: "Waduh, koneksi ke Gemini lagi bermasalah nih, bro.", 
        isUser: false,
      ));
    } finally {
      isLoading.value = false;
    }
  }
}