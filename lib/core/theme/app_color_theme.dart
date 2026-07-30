import 'package:flutter/material.dart';

enum AppColorTheme {
  plain(
    displayName: 'Plain',
    description: 'Minimal neutral & monochrome aesthetic',
    seedColor: Color(0xFF18181B),
    secondaryColor: Color(0xFF52525B),
  ),
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
    if (this == AppColorTheme.plain) {
      return const ColorScheme.light(
        primary: Color(0xFF18181B),
        onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFFF4F4F5),
        onPrimaryContainer: Color(0xFF18181B),
        secondary: Color(0xFF52525B),
        onSecondary: Color(0xFFFFFFFF),
        secondaryContainer: Color(0xFFE4E4E7),
        onSecondaryContainer: Color(0xFF18181B),
        surface: Color(0xFFFAFAFA),
        onSurface: Color(0xFF18181B),
        onSurfaceVariant: Color(0xFF71717A),
        surfaceContainerLowest: Color(0xFFFFFFFF),
        surfaceContainerLow: Color(0xFFF4F4F5),
        surfaceContainer: Color(0xFFE4E4E7),
        surfaceContainerHigh: Color(0xFFD4D4D8),
        surfaceContainerHighest: Color(0xFFA1A1AA),
        outline: Color(0xFFD4D4D8),
        outlineVariant: Color(0xFFE4E4E7),
        error: Color(0xFFEF4444),
        onError: Color(0xFFFFFFFF),
      );
    }
    return ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    );
  }

  /// Generates Material 3 Dark ColorScheme
  ColorScheme get darkScheme {
    if (this == AppColorTheme.plain) {
      return const ColorScheme.dark(
        primary: Color(0xFFFAFAFA),
        onPrimary: Color(0xFF18181B),
        primaryContainer: Color(0xFF27272A),
        onPrimaryContainer: Color(0xFFFAFAFA),
        secondary: Color(0xFFA1A1AA),
        onSecondary: Color(0xFF18181B),
        secondaryContainer: Color(0xFF3F3F46),
        onSecondaryContainer: Color(0xFFFAFAFA),
        surface: Color(0xFF09090B),
        onSurface: Color(0xFFFAFAFA),
        onSurfaceVariant: Color(0xFFA1A1AA),
        surfaceContainerLowest: Color(0xFF000000),
        surfaceContainerLow: Color(0xFF18181B),
        surfaceContainer: Color(0xFF27272A),
        surfaceContainerHigh: Color(0xFF3F3F46),
        surfaceContainerHighest: Color(0xFF52525B),
        outline: Color(0xFF3F3F46),
        outlineVariant: Color(0xFF27272A),
        error: Color(0xFFF87171),
        onError: Color(0xFF09090B),
      );
    }
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
