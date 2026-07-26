import 'package:flutter/material.dart';
import 'package:wooden_mill_app/core/theme/app_theme.dart';
import 'package:wooden_mill_app/core/theme/theme_controller.dart';
import 'package:wooden_mill_app/screens/history/history_screen.dart';
import 'package:wooden_mill_app/screens/home/home_screen.dart';
import 'package:wooden_mill_app/widgets/adaptive_scaffold.dart';

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
        return MaterialApp(
          title: 'Wooden Mill Calculator',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,
          home: const MainShell(),
        );
      },
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      selectedIndex: _navIndex,
      onDestinationSelected: (index) {
        setState(() {
          _navIndex = index;
        });
      },
      bodyPages: const [
        HomeScreen(),
        HistoryScreen(),
      ],
    );
  }
}
