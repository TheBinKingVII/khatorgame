import 'dart:async';
import 'dart:io';

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
import 'package:khatorgame/features/profile/presentation/pages/testimonial_page.dart';
import 'package:khatorgame/features/profile/presentation/pages/advice_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Timer? _connectivityTimer;

  @override
  void dispose() {
    _connectivityTimer?.cancel();
    super.dispose();
  }

  void _startConnectivityCheck(ProfileController controller) {
    _connectivityTimer?.cancel();
    _connectivityTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        final result = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 3));
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          timer.cancel();
          if (mounted) {
            controller.loadProfile();
          }
        }
      } catch (_) {
        // Masih offline, lanjut polling
      }
    });
  }

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
        
        // Auto-refresh: start timer if not active
        if (_connectivityTimer == null || !_connectivityTimer!.isActive) {
          _startConnectivityCheck(controller);
        }

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.redAccent),
                const SizedBox(height: 16),
                const Text(
                  'No Internet Connection',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.redAccent),
                ),
                const SizedBox(height: 8),
                Text(
                  'Waiting for internet connection to load profile...',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], height: 1.4),
                ),
                const SizedBox(height: 32),
                CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
              ],
            ),
          ),
        );
      }

      // Matikan timer jika load sudah sukses
      _connectivityTimer?.cancel();

      final profile = controller.profile.value;
      if (profile == null) {
        return const Center(child: Text('Profile unavailable.'));
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
                        'My Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Text(
                        'Manage your account and preferences',
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
                  title: 'Minigame',
                  subtitle: 'Play & earn Steam Vouchers!',
                  onTap: () {
                    context.push(AppRouter.minigamesPath);
                  },
                ),
              ],
            ),
            ProfileMenuSection(
              children: <Widget>[
                ProfileMenuTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Testimonial',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const TestimonialPage(),
                      ),
                    );
                  },
                ),
                ProfileMenuTile(
                  icon: Icons.gpp_good_outlined, 
                  title: 'Advice',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AdvicePage(),
                      ),
                    );
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: OutlinedButton.icon(
                onPressed: () async {
                  final bool? confirm = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: const Text('Confirm Logout', style: TextStyle(fontWeight: FontWeight.bold)),
                        content: const Text('Are you sure you want to log out of this account?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Yes, Log out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      );
                    },
                  );
                  
                  if (confirm == true) {
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
                  }
                },
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                label: const Text('Log out', style: TextStyle(color: Colors.redAccent)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
