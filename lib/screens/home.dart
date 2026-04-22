import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.child,
    required this.currentIndex,
    super.key,
  });

  final Widget child;
  final int currentIndex;

  static const List<String> _tabRoutes = <String>[
    '/deals',
    '/wishlist',
    '/chatbot',
    '/internetcafe',
    '/profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(padding: const EdgeInsets.only(top: 36), child: child),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          context.go(_tabRoutes[index]);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer_outlined),
            label: 'Deals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy_outlined),
            label: 'Chatbot',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.wifi), label: 'Cafe'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
