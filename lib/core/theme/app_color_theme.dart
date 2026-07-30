import 'package:flutter/material.dart';

enum AppColorTheme {
  timber(
    displayName: 'Timber',
    description: 'Warm wood, timber & workshop aesthetic',
    seedColor: Color(0xFF9E5429), // Warm Mahogany / Timber
    secondaryColor: Color(0xFF7C5843),
  ),
  forest(
    displayName: 'Forest',
    description: 'Earthy pine & natural green identity',
    seedColor: Color(0xFF2D6A4F), // Deep Forest Green
    secondaryColor: Color(0xFF52796F),
  ),
  emerald(
    displayName: 'Emerald',
    description: 'Clean modern teal & emerald identity',
    seedColor: Color(0xFF0F766E), // Emerald Teal
    secondaryColor: Color(0xFF14B8A6),
  ),
  ocean(
    displayName: 'Ocean',
    description: 'Vibrant marine & deep ocean identity',
    seedColor: Color(0xFF0284C7), // Deep Ocean Blue
    secondaryColor: Color(0xFF0369A1),
  ),
  indigo(
    displayName: 'Indigo',
    description: 'Modern indigo & business software aesthetic',
    seedColor: Color(0xFF4F46E5), // Modern Indigo
    secondaryColor: Color(0xFF6366F1),
  ),
  slate(
    displayName: 'Slate',
    description: 'Sophisticated neutral & steel aesthetic',
    seedColor: Color(0xFF475569), // Steel Slate
    secondaryColor: Color(0xFF64748B),
  );

  final String displayName;
  final String description;
  final Color seedColor;
  final Color secondaryColor;

  const AppColorTheme({
    required this.displayName,
    required this.description,
    required this.seedColor,
    required this.secondaryColor,
  });

  /// Generates Material 3 Light ColorScheme
  ColorScheme get lightScheme {
    return ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    );
  }

  /// Generates Material 3 Dark ColorScheme
  ColorScheme get darkScheme {
    return ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );
  }

  /// Color palette preview dots (Primary, Secondary, Surface)
  List<Color> getPreviewColors(bool isDark) {
    final scheme = isDark ? darkScheme : lightScheme;
    return [
      scheme.primary,
      scheme.secondary,
      scheme.primaryContainer,
    ];
  }
}
