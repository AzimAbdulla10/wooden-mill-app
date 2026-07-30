import 'package:flutter/material.dart';
import 'package:wooden_mill_app/core/theme/app_color_theme.dart';
import 'package:wooden_mill_app/core/theme/shadcn_tokens.dart';

class AppTheme {
  AppTheme._();

  static ThemeData buildTheme(AppColorTheme colorTheme, {required bool isDark}) {
    final colorScheme = isDark ? colorTheme.darkScheme : colorTheme.lightScheme;
    final cardColor = colorScheme.surfaceContainerLow;
    final borderColor = colorScheme.outlineVariant.withValues(alpha: 0.35);
    final inputBorderColor = colorScheme.outlineVariant;
    final mutedFg = colorScheme.onSurfaceVariant;

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
          fontSize: 17,
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
          side: BorderSide(color: borderColor, width: 0.8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        labelStyle: TextStyle(color: mutedFg, fontSize: 13, fontWeight: FontWeight.w500),
        hintStyle: TextStyle(color: mutedFg.withValues(alpha: 0.6), fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ShadTokens.radiusMd),
          borderSide: BorderSide(color: inputBorderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ShadTokens.radiusMd),
          borderSide: BorderSide(color: inputBorderColor, width: 1),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
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
          side: BorderSide(color: inputBorderColor, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ShadTokens.radiusMd),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ShadTokens.radiusSm),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
      ),
      dialogTheme: DialogThemeData(
        elevation: 0,
        backgroundColor: colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ShadTokens.radiusLg),
          side: BorderSide(color: borderColor, width: 0.8),
        ),
      ),
      chipTheme: ChipThemeData(
        elevation: 0,
        backgroundColor: colorScheme.surfaceContainerHigh,
        selectedColor: colorScheme.primaryContainer,
        secondarySelectedColor: colorScheme.primaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        labelStyle: TextStyle(fontSize: 12, color: colorScheme.onSurface),
        secondaryLabelStyle: TextStyle(fontSize: 12, color: colorScheme.onPrimaryContainer),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ShadTokens.radiusSm),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colorScheme.primary);
          }
          return TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.onPrimaryContainer);
          }
          return IconThemeData(color: colorScheme.onSurfaceVariant);
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: colorScheme.onPrimaryContainer),
        unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
        selectedLabelTextStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colorScheme.primary),
        unselectedLabelTextStyle: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
      ),
      snackBarTheme: SnackBarThemeData(
        elevation: 0,
        backgroundColor: isDark ? colorScheme.surfaceContainerHighest : colorScheme.onSurface,
        contentTextStyle: TextStyle(color: isDark ? colorScheme.onSurface : colorScheme.surface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ShadTokens.radiusSm),
        ),
      ),
    );
  }
}
