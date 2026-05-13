import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/auth_controller.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/categories/presentation/categories_screen.dart';
import '../features/channels/presentation/channel_list_screen.dart';
import '../features/channels/presentation/player_screen.dart';
import '../features/channels/presentation/search_screen.dart';
import '../features/favorites/presentation/favorites_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/shared/models/channel.dart';
import '../features/subscription/presentation/subscription_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/channels',
            builder: (context, state) => ChannelListScreen(
              category: state.uri.queryParameters['category'],
            ),
          ),
          GoRoute(
            path: '/categories',
            builder: (context, state) => const CategoriesScreen(),
          ),
          GoRoute(
            path: '/favorites',
            builder: (context, state) => const FavoritesScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/subscription',
        builder: (context, state) => const SubscriptionScreen(),
      ),
      GoRoute(
        path: '/player',
        builder: (context, state) {
          final channel = state.extra as Channel;
          return PlayerScreen(channel: channel);
        },
      ),
    ],
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final loading = auth.isLoading;
      final loggedIn = auth.valueOrNull != null;
      final loc = state.matchedLocation;
      if (loading && loc != '/splash') return '/splash';
      if (!loading && !loggedIn && loc == '/splash') return '/login';
      if (!loading &&
          !loggedIn &&
          !['/login', '/register', '/splash'].contains(loc)) {
        return '/login';
      }
      if (!loading &&
          loggedIn &&
          ['/login', '/register', '/splash'].contains(loc)) {
        return '/home';
      }
      return null;
    },
    refreshListenable: RouterRefreshListenable(ref),
  );
});

class MainScaffold extends StatelessWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  static const tabs = [
    '/home',
    '/channels',
    '/categories',
    '/favorites',
    '/profile',
  ];

  int _currentIndex(String location) {
    final index = tabs.indexWhere((t) => location.startsWith(t));
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _currentIndex(location);
    return Scaffold(
      body: child,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE0E0E0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x17000000),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) => context.go(tabs[index]),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
              NavigationDestination(
                icon: Icon(Icons.live_tv),
                label: 'Channels',
              ),
              NavigationDestination(
                icon: Icon(Icons.grid_view_rounded),
                label: 'Categories',
              ),
              NavigationDestination(
                icon: Icon(Icons.favorite),
                label: 'Favorites',
              ),
              NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}

class RouterRefreshListenable extends ChangeNotifier {
  RouterRefreshListenable(this.ref) {
    ref.listen(authControllerProvider, (previous, next) => notifyListeners());
  }
  final Ref ref;
}
