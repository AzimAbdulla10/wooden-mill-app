import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wooden_mill_app/screens/details/details_screen.dart';
import 'package:wooden_mill_app/screens/history/history_screen.dart';
import 'package:wooden_mill_app/screens/home/home_screen.dart';
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
          }

          return AdaptiveScaffold(
            selectedIndex: index,
            onDestinationSelected: (newIndex) {
              if (newIndex == 0) {
                context.go('/calculator');
              } else if (newIndex == 1) {
                context.go('/history');
              }
            },
            bodyPages: [
              // We pass child widget rendered by current GoRoute
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
