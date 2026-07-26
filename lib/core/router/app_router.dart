import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wooden_mill_app/screens/details/details_screen.dart';
import 'package:wooden_mill_app/screens/history/history_screen.dart';
import 'package:wooden_mill_app/screens/home/home_screen.dart';
import 'package:wooden_mill_app/screens/settings/settings_screen.dart';
import 'package:wooden_mill_app/widgets/adaptive_scaffold.dart';

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/calculator',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          int index = 0;
          final location = state.uri.path;
          if (location.startsWith('/history')) {
            index = 1;
          } else if (location.startsWith('/settings')) {
            index = 2;
          }

          return AdaptiveScaffold(
            selectedIndex: index,
            onDestinationSelected: (newIndex) {
              if (newIndex == 0) {
                context.go('/calculator');
              } else if (newIndex == 1) {
                context.go('/history');
              } else if (newIndex == 2) {
                context.go('/settings');
              }
            },
            bodyPages: [
              child,
            ],
          );
        },
        routes: [
          GoRoute(
            path: '/calculator',
            name: 'calculator',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/history',
            name: 'history',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HistoryScreen(),
            ),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/history/:id',
        name: 'orderDetails',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final idStr = state.pathParameters['id'];
          final id = int.tryParse(idStr ?? '') ?? 0;
          return DetailsScreen(orderId: id);
        },
      ),
    ],
  );
}
