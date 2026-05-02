import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:khatorgame/core/services/session_service.dart';
import 'package:khatorgame/features/auth/presentation/pages/auth_page.dart';
import 'package:khatorgame/features/auth/presentation/pages/login_page.dart';
import 'package:khatorgame/features/auth/presentation/pages/register_page.dart';
import 'package:khatorgame/features/chatbot/presentation/pages/chatbot_page.dart';
import 'package:khatorgame/features/deals/presentation/pages/deals_page.dart';
import 'package:khatorgame/features/internetcafe/presentation/pages/internetcafe_page.dart';
import 'package:khatorgame/features/minigames/presentation/pages/minigames_page.dart';
import 'package:khatorgame/features/profile/presentation/pages/profile_page.dart';
import 'package:khatorgame/features/profile/presentation/pages/biometric_settings_page.dart';
import 'package:khatorgame/features/wishlist/presentation/pages/wishlist_page.dart';
import 'package:khatorgame/screens/home.dart';

class AppRouter {
  static const String dealsPath = '/deals';
  static const String wishlistPath = '/wishlist';
  static const String chatbotPath = '/chatbot';
  static const String internetcafePath = '/internetcafe';
  static const String minigamesPath = '/minigames';
  static const String profilePath = '/profile';
  static const String authPath = '/auth';
  static const String loginPath = '/login';
  static const String registerPath = '/register';
  static const String biometricSettingsPath = '/biometric-settings';

  static final GoRouter router = GoRouter(
    // initialLocation: dealsPath,
    initialLocation: SessionService.instance.hasValidSession
        ? dealsPath
        : loginPath,
    refreshListenable: SessionService.instance,
    redirect: (BuildContext context, GoRouterState state) {
      final bool isLoggedIn = SessionService.instance.hasValidSession;
      final bool isAuthRoute =
          state.uri.path == loginPath || state.uri.path == registerPath;

      if (!isLoggedIn && !isAuthRoute) {
        return loginPath;
      }

      if (isLoggedIn && isAuthRoute) {
        return dealsPath;
      }

      return null;
    },
    routes: <RouteBase>[
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) {
          final String location = state.uri.path;
          final int index = _tabIndexFromLocation(location);

          return HomeScreen(
            currentIndex: index,
            child: child,
          );
        },
        routes: <RouteBase>[
          GoRoute(
            path: dealsPath,
            builder: (BuildContext context, GoRouterState state) =>
                const DealsPage(),
          ),
          GoRoute(
            path: wishlistPath,
            builder: (BuildContext context, GoRouterState state) =>
                const WishlistPage(),
          ),
          GoRoute(
            path: chatbotPath,
            builder: (BuildContext context, GoRouterState state) =>
                const ChatbotPage(),
          ),
          GoRoute(
            path: internetcafePath,
            builder: (BuildContext context, GoRouterState state) =>
                InternetcafePage(),
          ),
          GoRoute(
            path: minigamesPath,
            builder: (BuildContext context, GoRouterState state) =>
                const MinigamesPage(),
          ),
          GoRoute(
            path: profilePath,
            builder: (BuildContext context, GoRouterState state) =>
                const ProfilePage(),
          ),
        ],
      ),
      GoRoute(
        path: authPath,
        builder: (BuildContext context, GoRouterState state) => const AuthPage(),
      ),
      GoRoute(
        path: loginPath,
        builder: (BuildContext context, GoRouterState state) => const LoginPage(),
      ),
      GoRoute(
        path: registerPath,
        builder: (BuildContext context, GoRouterState state) =>
            const RegisterPage(),
      ),
      GoRoute(
        path: biometricSettingsPath,
        builder: (BuildContext context, GoRouterState state) =>
            const BiometricSettingsPage(),
      ),
    ],
  );

  static int _tabIndexFromLocation(String location) {
    if (location.startsWith(wishlistPath)) return 1;
    if (location.startsWith(chatbotPath)) return 2;
    if (location.startsWith(internetcafePath)) return 3;
    // Minigames route is kept, but no longer shown as bottom tab.
    if (location.startsWith(minigamesPath)) return 4;
    if (location.startsWith(profilePath)) return 4;
    return 0;
  }
}
