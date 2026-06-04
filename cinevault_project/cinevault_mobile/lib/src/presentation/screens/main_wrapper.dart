import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cineflash/src/core/theme/app_theme.dart';
import 'package:cineflash/src/core/router/app_router.dart';

class MainWrapper extends StatelessWidget {
  final Widget child;

  const MainWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: context.textSecondary,
        backgroundColor: context.surface,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_rounded), label: 'Watchlist'),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle_rounded), label: 'Seen'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location == AppRoutes.home) return 0;
    if (location == AppRoutes.search) return 1;
    if (location == AppRoutes.watchlist) return 2;
    if (location == AppRoutes.watched) return 3;
    if (location == AppRoutes.profile) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.search);
        break;
      case 2:
        context.go(AppRoutes.watchlist);
        break;
      case 3:
        context.go(AppRoutes.watched);
        break;
      case 4:
        context.go(AppRoutes.profile);
        break;
    }
  }
}
