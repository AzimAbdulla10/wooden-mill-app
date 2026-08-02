import 'package:flutter/material.dart';
import 'package:wooden_mill_app/core/controllers/wood_type_controller.dart';
import 'package:wooden_mill_app/core/router/app_router.dart';
import 'package:wooden_mill_app/core/theme/app_theme.dart';
import 'package:wooden_mill_app/core/theme/theme_controller.dart';

final ThemeController themeController = ThemeController();
final WoodTypeController woodTypeController = WoodTypeController();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await woodTypeController.loadWoodTypes();
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
          theme: AppTheme.buildTheme(themeController.colorTheme, isDark: false),
          darkTheme: AppTheme.buildTheme(themeController.colorTheme, isDark: true),
          themeMode: themeController.themeMode,
          routerConfig: AppRouter.router,
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            final systemTextScaler = mediaQuery.textScaler;
            final densityScale = themeController.displayDensity.scaleFactor;

            return MediaQuery(
              data: mediaQuery.copyWith(
                textScaler: TextScaler.linear(systemTextScaler.scale(1.0) * densityScale),
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}
