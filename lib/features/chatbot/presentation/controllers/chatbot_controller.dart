import 'package:get/get.dart';
import 'package:khatorgame/features/deals/presentation/controllers/deals_controller.dart';
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
      String secretContext = "";

      // 2. Panggil DealsController yang sudah terhubung ke API
      // Pakai Get.put agar kalau controller belum diregister, GetX bakal buatin
      final dealsController = Get.put(DealsController());
      
      // 3. Pastikan data sudah diload dari API. Jika masih kosong, paksa load!
      if (dealsController.deals.isEmpty) {
        await dealsController.loadInitialDeals();
      }
      
      // 4. Jika data dari API berhasil didapat
      if (dealsController.deals.isNotEmpty) {
        // TIPS PRO: Karena API mengembalikan banyak data (bisa puluhan/ratusan),
        // kita ambil maksimal 20 atau 30 game pertama saja agar prompt tidak melebihi 
        // batas maksimal token Gemini dan tidak lemot.
        final topDeals = dealsController.deals.take(30).toList();
        
        // Mapping properti sesuai dengan DealsEntity buatan temanmu
        final listDiskon = topDeals.map((game) => 
          "- ${game.title}: Harga normal \$${game.normalPrice}, sekarang diskon jadi \$${game.salePrice} (Hemat ${game.savingsAsPercent}%)"
        ).join('\n');
        
        // 5. Suntikkan instruksi tegas ke AI
        secretContext = "SISTEM INFO RAHASIA: Berikut adalah daftar game PC yang sedang diskon saat ini dari API CheapShark:\n$listDiskon\n\nINSTRUKSI WAJIB: Kamu adalah asisten Khator Game. Jawab pertanyaan user berikut INI SAJA berdasarkan daftar di atas. Jika user mencari game yang tidak ada di daftar ini, bilang 'Berdasarkan data saat ini, game tersebut belum diskon'. JANGAN berhalusinasi atau memberikan harga dari ingatanmu.\n\n";
      }

      final enrichedPrompt = secretContext + "Pertanyaan User: " + prompt;

      // Pantau prompt yang akan dikirim di terminal
      print("DEBUG ENRICHED PROMPT:\n$enrichedPrompt");

      final response = await usecase.execute(enrichedPrompt);
      
      messages.add(response);
    } catch (e) {
      print("Error AI: $e");
      messages.add(ChatbotEntity(
        text: "Waduh, koneksi ke Gemini lagi bermasalah nih", 
        isUser: false,
      ));
    } finally {
      isLoading.value = false;
    }
  }
}