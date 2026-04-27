import 'dart:io';
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
      // 1. Cek Koneksi Internet Dulu
      try {
        final result = await InternetAddress.lookup('google.com')
            .timeout(const Duration(seconds: 3));
        if (result.isEmpty || result[0].rawAddress.isEmpty) {
          throw Exception('Koneksi terputus. Pastikan jaringan internet stabil!');
        }
      } catch (_) {
        throw Exception('Koneksi terputus. Pastikan jaringan internet stabil!');
      }

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
        
        // 5. Suntikkan instruksi tegas ke AI namun tetap ramah
        secretContext = """
SYSTEM INSTRUCTIONS:
Kamu adalah "Khator Assistant", AI pintar, ramah, dan asyik bergaya anak gamers yang bertugas membantu user di aplikasi "Khator Game".

Berikut adalah data LIVE diskon game PC saat ini dari API:
$listDiskon

Aturan menjawab:
1. Jika user bertanya soal harga, diskon, atau rekomendasi game murah, WAJIB gunakan data di atas. Jika game yang dicari tidak ada di list, bilang jujur bahwa game tersebut sedang tidak ada diskon di data saat ini.
2. Jika user bertanya seputar detail game (cerita, genre, review, spesifikasi PC), gunakan pengetahuan bawaanmu sendiri sebagai AI untuk menjelaskannya selengkap dan semenarik mungkin!
3. Jika user bertanya hal umum, basa-basi, atau nanya siapa kamu/kamu pakai model apa, jawablah dengan santai dan ramah selayaknya teman ngobrol.

""";
      }

      final enrichedPrompt = "$secretContext\n\n[Pesan User]: $prompt";

      // Pantau prompt yang akan dikirim di terminal
      print("DEBUG ENRICHED PROMPT:\n$enrichedPrompt");

      final response = await usecase.execute(enrichedPrompt);
      
      messages.add(response);
    } catch (e) {
      print("Error AI: $e");
      
      String errText = e.toString();
      // Hilangkan awalan "Exception: " yang otomatis ditambah oleh Dart
      if (errText.startsWith('Exception: ')) {
        errText = errText.substring(11);
      }

      messages.add(ChatbotEntity(
        text: errText, 
        isUser: false,
      ));
    } finally {
      isLoading.value = false;
    }
  }
}