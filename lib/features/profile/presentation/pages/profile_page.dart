import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'package:khatorgame/core/router/app_router.dart';
import 'package:khatorgame/core/utils/supabase_user_message.dart';
import 'package:khatorgame/features/auth/domain/repositories/auth_repository.dart';
import 'package:khatorgame/features/profile/presentation/controllers/profile_controller.dart';
import 'package:khatorgame/features/profile/presentation/pages/currency_page.dart';
import 'package:khatorgame/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:khatorgame/features/profile/presentation/pages/notification_settings_page.dart';
import 'package:khatorgame/features/profile/presentation/widgets/profile_header_card.dart';
import 'package:khatorgame/features/profile/presentation/widgets/profile_menu_section.dart';
import 'package:khatorgame/features/profile/presentation/widgets/profile_menu_tile.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find<ProfileController>();
    final AuthRepository authRepository = Get.find<AuthRepository>();

    return Obx(() {
      if (controller.isLoading.value && controller.profile.value == null) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.value != null &&
          controller.profile.value == null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Gagal memuat profil.\n${controller.errorMessage.value}',
              textAlign: TextAlign.center,
            ),
          ),
        );
      }

      final profile = controller.profile.value;
      if (profile == null) {
        return const Center(child: Text('Profil tidak tersedia.'));
      }

      return RefreshIndicator(
        onRefresh: controller.loadProfile,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 16),
          children: <Widget>[
            // ─── Gradient Header ─────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profil Saya',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Text(
                        'Kelola akun dan preferensi',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            ProfileHeaderCard(
              profile: profile,
              pendingAvatarPath: controller.pendingAvatarPath.value,
              onEditTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const EditProfilePage(),
                  ),
                );
              },
            ),
            ProfileMenuSection(
              children: <Widget>[
                ProfileMenuTile(
                  icon: Icons.attach_money_outlined,
                  title: 'Currency',
                  subtitle: profile.currencyCode,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const CurrencyPage(),
                      ),
                    );
                  },
                ),
                ProfileMenuTile(
                  icon: Icons.fingerprint_outlined,
                  title: 'Biometric Login',
                  subtitle: controller.isBiometricEnabled.value
                      ? 'Enabled'
                      : 'Disabled',
                  onTap: () {
                    context.push('/biometric-settings');
                  },
                ),
                ProfileMenuTile(
                  icon: Icons.notifications_none_outlined,
                  title: 'Notifications',
                  subtitle: profile.notificationsEnabled
                      ? 'Enabled'
                      : 'Disabled',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const NotificationSettingsPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
            ProfileMenuSection(
              children: <Widget>[
                ProfileMenuTile(
                  icon: Icons.videogame_asset_outlined,
                  title: 'Gudang Gear (Minigame)',
                  subtitle: 'Main & dapatkan Voucher Steam!',
                  onTap: () {
                    context.push(AppRouter.minigamesPath);
                  },
                ),
              ],
            ),
            const ProfileMenuSection(
              children: <Widget>[
                ProfileMenuTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Testimonial',
                ),
                ProfileMenuTile(icon: Icons.gpp_good_outlined, title: 'Advice'),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: OutlinedButton.icon(
                onPressed: () async {
                  try {
                    await authRepository.logout();
                    if (!context.mounted) return;
                    context.go('/login');
                  } catch (error) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(supabaseUserMessage(error))),
                    );
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Log out'),
              ),
            ),
          ],
        ),
      );
    });
  }
}
