import 'package:flutter/material.dart';
import 'package:wooden_mill_app/core/router/app_router.dart';
import 'package:wooden_mill_app/core/theme/app_theme.dart';
import 'package:wooden_mill_app/core/theme/theme_controller.dart';

final ThemeController themeController = ThemeController();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Timbr',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
