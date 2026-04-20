import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'package:khatorgame/core/router/app_router.dart';
import 'package:khatorgame/core/utils/supabase_user_message.dart';
import 'package:khatorgame/features/auth/data/repositories/auth_repository_impl.dart';
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
    final AuthRepositoryImpl authRepository = AuthRepositoryImpl();

    return Obx(() {
      if (controller.isLoading.value && controller.profile.value == null) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.value != null && controller.profile.value == null) {
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
          padding: const EdgeInsets.only(top: 12, bottom: 16),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: <Widget>[
                  const Expanded(
                    child: Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.more_horiz),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ProfileHeaderCard(
              profile: profile,
              onEditTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const EditProfilePage()),
                );
              },
            ),
            ProfileMenuSection(
              children: <Widget>[
                ProfileMenuTile(
                  icon: Icons.edit_location_alt_outlined,
                  title: 'Address Book',
                  subtitle: 'Manage your saved addresses',
                ),
                ProfileMenuTile(
                  icon: Icons.receipt_long_outlined,
                  title: 'Order History',
                  subtitle: 'View your past orders',
                ),
                ProfileMenuTile(
                  icon: Icons.attach_money_outlined,
                  title: 'Currency',
                  subtitle: profile.currencyCode,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const CurrencyPage()),
                    );
                  },
                ),
                ProfileMenuTile(
                  icon: Icons.notifications_none_outlined,
                  title: 'Notifications',
                  subtitle: profile.notificationsEnabled ? 'Enabled' : 'Disabled',
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
                  icon: Icons.contact_support_outlined,
                  title: 'Contact Us',
                ),
                ProfileMenuTile(
                  icon: Icons.help_outline,
                  title: 'Get Help',
                ),
                ProfileMenuTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                ),
                ProfileMenuTile(
                  icon: Icons.gpp_good_outlined,
                  title: 'Terms & Conditions',
                ),
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

