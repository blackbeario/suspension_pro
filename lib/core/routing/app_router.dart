import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ridemetrx/features/auth/domain/user_notifier.dart';
import 'package:ridemetrx/features/auth/presentation/screens/login_page.dart';
import 'package:ridemetrx/features/bikes/presentation/screens/bikes_list_screen.dart';
import 'package:ridemetrx/features/onboarding/presentation/screens/onboarding.dart';
import 'package:ridemetrx/features/profile/presentation/screens/profile_screen.dart';
import 'package:ridemetrx/features/ai/presentation/screens/ai_request_screen.dart';

part 'app_router.g.dart';

/// Router configuration provider
/// Provides go_router instance with auth redirect logic
@riverpod
GoRouter appRouter(Ref ref) {
  final userState = ref.watch(userNotifierProvider);

  return GoRouter(
    initialLocation: '/onboarding',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthenticated = userState.isAuthenticated;
      final isOnboarding = state.matchedLocation == '/onboarding';
      final isLogin = state.matchedLocation == '/login';

      // If not authenticated and not on login/onboarding, go to login
      if (!isAuthenticated && !isLogin && !isOnboarding) {
        return '/login';
      }

      // If authenticated and on login, go to home
      if (isAuthenticated && isLogin) {
        return '/home';
      }

      return null; // No redirect needed
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => Onboarding(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => LoginPage(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => BikesListScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/ai',
            name: 'ai',
            builder: (context, state) => const AiRequestScreen(),
          ),
        ],
      ),
    ],
  );
}

/// Shell widget for bottom navigation
/// Replaces the CupertinoTabScaffold with go_router navigation
class AppShell extends StatefulWidget {
  final Widget child;

  const AppShell({Key? key, required this.child}) : super(key: key);

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  void _onItemTapped(int index, BuildContext context) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/profile');
        break;
      case 2:
        context.go('/ai');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract the current route to set the selected index
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/home')) {
      _selectedIndex = 0;
    } else if (location.startsWith('/profile')) {
      _selectedIndex = 1;
    } else if (location.startsWith('/ai')) {
      _selectedIndex = 2;
    }

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => _onItemTapped(index, context),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.format_list_bulleted_rounded),
            label: 'Bikes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            label: 'Account',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy_outlined),
            label: 'AI',
          ),
        ],
      ),
    );
  }
}
