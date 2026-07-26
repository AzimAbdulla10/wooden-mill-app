import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppDisplayDensity {
  compact(0.9, 'Compact'),
  recommended(1.0, 'Recommended'),
  large(1.1, 'Large'),
  extraLarge(1.2, 'Extra Large');

  final double scaleFactor;
  final String label;
  const AppDisplayDensity(this.scaleFactor, this.label);
}

class ThemeController extends ChangeNotifier {
  static const String _themePrefKey = 'theme_mode';
  static const String _densityPrefKey = 'display_density';

  ThemeMode _themeMode = ThemeMode.system;
  AppDisplayDensity _displayDensity = AppDisplayDensity.recommended;

  ThemeMode get themeMode => _themeMode;
  AppDisplayDensity get displayDensity => _displayDensity;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeController() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load Theme
      final savedTheme = prefs.getString(_themePrefKey);
      if (savedTheme != null) {
        if (savedTheme == 'light') {
          _themeMode = ThemeMode.light;
        } else if (savedTheme == 'dark') {
          _themeMode = ThemeMode.dark;
        } else {
          _themeMode = ThemeMode.system;
        }
      }

      // Load Density
      final savedDensity = prefs.getString(_densityPrefKey);
      if (savedDensity != null) {
        _displayDensity = AppDisplayDensity.values.firstWhere(
          (d) => d.name == savedDensity,
          orElse: () => AppDisplayDensity.recommended,
        );
      }

      notifyListeners();
    } catch (_) {
      // Ignore prefs error and use defaults
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      String val = 'system';
      if (mode == ThemeMode.light) val = 'light';
      if (mode == ThemeMode.dark) val = 'dark';
      await prefs.setString(_themePrefKey, val);
    } catch (_) {}
  }

  Future<void> setDisplayDensity(AppDisplayDensity density) async {
    if (_displayDensity == density) return;
    _displayDensity = density;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_densityPrefKey, density.name);
    } catch (_) {}
  }

  Future<void> toggleTheme(BuildContext context) async {
    final currentBrightness = Theme.of(context).brightness;
    if (currentBrightness == Brightness.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }

  Future<void> resetSettings() async {
    _themeMode = ThemeMode.system;
    _displayDensity = AppDisplayDensity.recommended;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_themePrefKey);
      await prefs.remove(_densityPrefKey);
    } catch (_) {}
  }
}
