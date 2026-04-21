import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/localization/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/listings_provider.dart';
import 'home/home_screen.dart';
import 'favorites/favorites_screen.dart';
import 'chat/conversations_screen.dart';
import 'my_listings/my_listings_screen.dart';
import 'profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    FavoritesScreen(),
    ConversationsScreen(),
    MyListingsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            // Tabs that require login: Favorites(1), Chat(2), My Listings(3)
            if (index == 1 || index == 2 || index == 3) {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              if (!auth.isLoggedIn) {
                _showLoginRequired(context);
                return;
              }
            }
            // Refresh data when navigating to specific tabs
            if (index == 1) {
              // Favorites tab
              Provider.of<ListingsProvider>(
                context,
                listen: false,
              ).fetchFavorites();
            } else if (index == 3) {
              // My Listings tab
              Provider.of<ListingsProvider>(
                context,
                listen: false,
              ).fetchMyListings();
            }
            setState(() => _currentIndex = index);
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_rounded),
              label: context.tr('home'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.favorite_rounded),
              label: context.tr('favorites'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.chat_bubble_rounded),
              label: context.tr('messages'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.list_alt_rounded),
              label: context.tr('my_listings'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_rounded),
              label: context.tr('profile'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLoginRequired(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.tr('login')),
        action: SnackBarAction(
          label: context.tr('login'),
          onPressed: () {
            Navigator.pushNamed(context, '/login');
          },
        ),
      ),
    );
  }
}
