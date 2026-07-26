import 'package:flutter/material.dart';
import 'package:wooden_mill_app/core/theme/shadcn_tokens.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final colorScheme = const ColorScheme.light().copyWith(
      surface: ShadTokens.lightBackground,
      onSurface: ShadTokens.lightForeground,
      primary: ShadTokens.lightPrimary,
      onPrimary: ShadTokens.lightPrimaryForeground,
      secondary: ShadTokens.lightSecondary,
      onSecondary: ShadTokens.lightSecondaryForeground,
      error: ShadTokens.lightDestructive,
      onError: ShadTokens.lightDestructiveForeground,
      outline: ShadTokens.lightBorder,
      outlineVariant: ShadTokens.lightInput,
      surfaceContainerHighest: ShadTokens.lightMuted,
      onSurfaceVariant: ShadTokens.lightMutedForeground,
    );

    return _buildShadTheme(colorScheme, isDark: false);
  }

  static ThemeData get darkTheme {
    final colorScheme = const ColorScheme.dark().copyWith(
      surface: ShadTokens.darkBackground,
      onSurface: ShadTokens.darkForeground,
      primary: ShadTokens.darkPrimary,
      onPrimary: ShadTokens.darkPrimaryForeground,
      secondary: ShadTokens.darkSecondary,
      onSecondary: ShadTokens.darkSecondaryForeground,
      error: ShadTokens.darkDestructive,
      onError: ShadTokens.darkDestructiveForeground,
      outline: ShadTokens.darkBorder,
      outlineVariant: ShadTokens.darkInput,
      surfaceContainerHighest: ShadTokens.darkMuted,
      onSurfaceVariant: ShadTokens.darkMutedForeground,
    );

    return _buildShadTheme(colorScheme, isDark: true);
  }

  static ThemeData _buildShadTheme(ColorScheme colorScheme, {required bool isDark}) {
    final cardColor = isDark ? ShadTokens.darkCard : ShadTokens.lightCard;
    final borderColor = isDark ? ShadTokens.darkBorder : ShadTokens.lightBorder;
    final mutedFg = isDark ? ShadTokens.darkMutedForeground : ShadTokens.lightMutedForeground;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      dividerTheme: DividerThemeData(
        color: borderColor,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        shape: Border(bottom: BorderSide(color: borderColor, width: 1)),
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardColor,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ShadTokens.radiusMd),
          side: BorderSide(color: borderColor, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        labelStyle: TextStyle(color: mutedFg, fontSize: 14, fontWeight: FontWeight.w500),
        hintStyle: TextStyle(color: mutedFg.withValues(alpha: 0.7), fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ShadTokens.radiusMd),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ShadTokens.radiusMd),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ShadTokens.radiusMd),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ShadTokens.radiusMd),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ShadTokens.radiusMd),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ShadTokens.radiusMd),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(color: borderColor, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ShadTokens.radiusMd),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ShadTokens.radiusSm),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
      ),
      dialogTheme: DialogThemeData(
        elevation: 0,
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ShadTokens.radiusLg),
          side: BorderSide(color: borderColor, width: 1),
        ),
      ),
    );
  }
}
