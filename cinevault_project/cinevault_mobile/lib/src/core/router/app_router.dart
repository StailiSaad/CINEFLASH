import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cineflash/src/presentation/screens/auth/login_screen.dart';
import 'package:cineflash/src/presentation/screens/home/home_screen.dart';
import 'package:cineflash/src/presentation/screens/details/movie_details_screen.dart';
import 'package:cineflash/src/presentation/screens/search/search_screen.dart';
import 'package:cineflash/src/presentation/screens/watchlist/watchlist_screen.dart';
import 'package:cineflash/src/presentation/screens/watched/watched_screen.dart';
import 'package:cineflash/src/presentation/screens/profile/profile_screen.dart';

import 'package:cineflash/src/presentation/screens/main_wrapper.dart';

class AppRoutes {
  static const String home = '/';
  static const String movieDetails = '/movie/:id';
  static const String tvDetails = '/tv/:id';
  static const String search = '/search';
  static const String watchlist = '/watchlist';
  static const String watched = '/watched';
  static const String profile = '/profile';
  static const String login = '/login';
}

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.home,
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final loggingIn = state.matchedLocation == AppRoutes.login;
      
      if (session == null) {
        return AppRoutes.login;
      }
      
      if (loggingIn) {
        return AppRoutes.home;
      }
      
      return null;
    },
    routes: [
      // Routes WITH the persistent bottom bar
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainWrapper(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.search,
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: AppRoutes.watchlist,
            builder: (context, state) => const WatchlistScreen(),
          ),
          GoRoute(
            path: AppRoutes.watched,
            builder: (context, state) => const WatchedScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Routes WITHOUT the bottom bar (Fullscreen Activities)
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/movie/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return MovieDetailsScreen(movieId: id);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/tv/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return MovieDetailsScreen(movieId: id, isTv: true);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
    ],
  );
}