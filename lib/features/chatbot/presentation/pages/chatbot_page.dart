import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:khatorgame/core/utils/input_validator.dart';
import '../controllers/chatbot_controller.dart';

class ChatbotPage extends StatelessWidget {
  final TextEditingController _textController = TextEditingController();

  ChatbotPage({Key? key}) : super(key: key);

  void _handleSend(BuildContext context, ChatbotController controller) {
    final String text = _textController.text.trim();
    final String? validationMessage = InputValidator.validateChatMessage(text);
    if (validationMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(validationMessage)));
      return;
    }
    controller.sendMessage(text);
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatbotController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Khator AI Assistant'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Area Chat (Reactive dengan Obx)
          Expanded(
            child: Obx(() => ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: controller.messages.length,
              itemBuilder: (context, index) {
                final message = controller.messages[index];
                return _buildChatBubble(context,message);
              },
            )),
          ),
          
          // Indikator Loading
          Obx(() => controller.isLoading.value 
            ? const LinearProgressIndicator() 
            : const SizedBox.shrink()),

          // Input Field
          _buildInputArea(context, controller),
        ],
      ),
    );
  }

  Widget _buildChatBubble(BuildContext context, message) {
    bool isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? Colors.deepPurple : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: Radius.circular(isUser ? 15 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 15),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(color: isUser ? Colors.white : Colors.black87),
        ),
      ),
    );
  }

  Widget _buildInputArea(BuildContext context, ChatbotController controller) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              inputFormatters: InputValidator.chatFormatters,
              decoration: InputDecoration(
                hintText: 'Tanya soal game atau diskon...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              onSubmitted: (_) => _handleSend(context, controller),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: () => _handleSend(context, controller),
            icon: const Icon(Icons.send, color: Colors.deepPurple),
          ),
        ],
      ),
    );
  }
}