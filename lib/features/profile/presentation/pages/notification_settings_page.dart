import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:khatorgame/features/profile/presentation/controllers/profile_controller.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find<ProfileController>();

    return Obx(() {
      final profile = controller.profile.value;
      if (profile == null) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      return Scaffold(
        appBar: AppBar(title: const Text('Notifications')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            SwitchListTile(
              value: profile.notificationsEnabled,
              title: const Text('Push Notification'),
              subtitle: Text(
                profile.notificationsEnabled
                    ? 'Notifications are enabled'
                    : 'Notifications are disabled',
              ),
              onChanged: controller.isSaving.value
                  ? null
                  : (bool enabled) async {
                      await controller.saveNotification(enabled);
                    },
            ),
          ],
        ),
      );
    });
  }
}

