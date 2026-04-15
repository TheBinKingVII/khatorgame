import 'package:flutter/material.dart';
import 'package:khatorgame/features/chatbot/presentation/pages/chatbot_page.dart';
import 'package:khatorgame/features/deals/presentation/pages/deals_page.dart';
import 'package:khatorgame/features/internetcafe/presentation/pages/internetcafe_page.dart';
import 'package:khatorgame/features/minigames/presentation/pages/minigames_page.dart';
import 'package:khatorgame/features/wishlist/presentation/pages/wishlist_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DealsPage(),
    WishlistPage(),
    ChatbotPage(),
    InternetcafePage(),
    MinigamesPage(),
  ];

  final List<String> _titles = const [
    'Deals',
    'Wishlist',
    'Chatbot',
    'Internet Cafe',
    'Minigames',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
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
          BottomNavigationBarItem(
            icon: Icon(Icons.wifi),
            label: 'Internet Cafe',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_esports_outlined),
            label: 'Minigames',
          ),
        ],
      ),
    );
  }
}
