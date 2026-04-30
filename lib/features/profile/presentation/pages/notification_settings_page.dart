import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:khatorgame/features/profile/presentation/controllers/profile_controller.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find<ProfileController>();
    final Color accentColor = Theme.of(context).colorScheme.primary;

    return Obx(() {
      final profile = controller.profile.value;
      if (profile == null) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      return Scaffold(
        appBar: AppBar(
          toolbarHeight: 72,
          title: const Text(
            'Notifications',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            SwitchListTile(
              value: profile.notificationsEnabled,
              activeThumbColor: Colors.white,
              activeTrackColor: accentColor,
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
