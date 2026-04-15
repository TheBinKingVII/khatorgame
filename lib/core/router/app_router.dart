import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:khatorgame/features/auth/presentation/pages/auth_page.dart';
import 'package:khatorgame/features/chatbot/presentation/pages/chatbot_page.dart';
import 'package:khatorgame/features/deals/presentation/pages/deals_page.dart';
import 'package:khatorgame/features/internetcafe/presentation/pages/internetcafe_page.dart';
import 'package:khatorgame/features/minigames/presentation/pages/minigames_page.dart';
import 'package:khatorgame/features/wishlist/presentation/pages/wishlist_page.dart';
import 'package:khatorgame/screens/home.dart';

class AppRouter {
  static const String dealsPath = '/deals';
  static const String wishlistPath = '/wishlist';
  static const String chatbotPath = '/chatbot';
  static const String internetcafePath = '/internetcafe';
  static const String minigamesPath = '/minigames';
  static const String authPath = '/auth';

  static final GoRouter router = GoRouter(
    initialLocation: dealsPath,
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
                const InternetcafePage(),
          ),
          GoRoute(
            path: minigamesPath,
            builder: (BuildContext context, GoRouterState state) =>
                const MinigamesPage(),
          ),
        ],
      ),
      GoRoute(
        path: authPath,
        builder: (BuildContext context, GoRouterState state) => const AuthPage(),
      ),
    ],
  );

  static int _tabIndexFromLocation(String location) {
    if (location.startsWith(wishlistPath)) return 1;
    if (location.startsWith(chatbotPath)) return 2;
    if (location.startsWith(internetcafePath)) return 3;
    if (location.startsWith(minigamesPath)) return 4;
    return 0;
  }
}
