import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:khatorgame/features/profile/presentation/controllers/profile_controller.dart';

class CurrencyPage extends StatelessWidget {
  const CurrencyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find<ProfileController>();

    return Obx(() {
      final profile = controller.profile.value;
      if (profile == null) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      return Scaffold(
        appBar: AppBar(title: const Text('Currency')),
        body: ListView.builder(
          itemCount: controller.currencies.length,
          itemBuilder: (BuildContext context, int index) {
            final option = controller.currencies[index];
            final bool selected = option.code == profile.currencyCode;
            return ListTile(
              leading: Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
              ),
              title: Text('${option.label} (${option.symbol})'),
              subtitle: Text(option.code),
              onTap: controller.isSaving.value
                  ? null
                  : () async {
                      await controller.saveCurrency(option.code);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Mata uang diubah ke ${option.label} (${option.symbol})',
                          ),
                        ),
                      );
                      Navigator.of(context).pop();
                    },
            );
          },
        ),
      );
    });
  }
}

