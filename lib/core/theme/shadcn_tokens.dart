import 'package:flutter/material.dart';

/// Design tokens inspired by shadcn/ui design system
class ShadTokens {
  ShadTokens._();

  // Radii
  static const double radiusSm = 6.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;

  // Spacing Scale
  static const double space2xs = 2.0;
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 12.0;
  static const double spaceLg = 16.0;
  static const double spaceXl = 24.0;
  static const double space2xl = 32.0;

  // Light Color Tokens (Slate / Zinc Neutral Palette)
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightForeground = Color(0xFF0F172A);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardForeground = Color(0xFF0F172A);
  static const Color lightPopover = Color(0xFFFFFFFF);
  static const Color lightPopoverForeground = Color(0xFF0F172A);
  static const Color lightPrimary = Color(0xFF0F172A); // Zinc 900
  static const Color lightPrimaryForeground = Color(0xFFF8FAFC);
  static const Color lightSecondary = Color(0xFFF1F5F9); // Slate 100
  static const Color lightSecondaryForeground = Color(0xFF0F172A);
  static const Color lightMuted = Color(0xFFF1F5F9);
  static const Color lightMutedForeground = Color(0xFF64748B); // Slate 500
  static const Color lightAccent = Color(0xFFF1F5F9);
  static const Color lightAccentForeground = Color(0xFF0F172A);
  static const Color lightDestructive = Color(0xFFEF4444); // Red 500
  static const Color lightDestructiveForeground = Color(0xFFF8FAFC);
  static const Color lightBorder = Color(0xFFE2E8F0); // Slate 200
  static const Color lightInput = Color(0xFFE2E8F0);
  static const Color lightRing = Color(0xFF94A3B8);

  // Dark Color Tokens (Zinc Dark Palette)
  static const Color darkBackground = Color(0xFF09090B); // Zinc 950
  static const Color darkForeground = Color(0xFFF8FAFC);
  static const Color darkCard = Color(0xFF18181B); // Zinc 900
  static const Color darkCardForeground = Color(0xFFF8FAFC);
  static const Color darkPopover = Color(0xFF18181B);
  static const Color darkPopoverForeground = Color(0xFFF8FAFC);
  static const Color darkPrimary = Color(0xFFF8FAFC); // Zinc 50
  static const Color darkPrimaryForeground = Color(0xFF09090B);
  static const Color darkSecondary = Color(0xFF27272A); // Zinc 800
  static const Color darkSecondaryForeground = Color(0xFFF8FAFC);
  static const Color darkMuted = Color(0xFF27272A);
  static const Color darkMutedForeground = Color(0xFFA1A1AA); // Zinc 400
  static const Color darkAccent = Color(0xFF27272A);
  static const Color darkAccentForeground = Color(0xFFF8FAFC);
  static const Color darkDestructive = Color(0xFF7F1D1D); // Red 900
  static const Color darkDestructiveForeground = Color(0xFFF8FAFC);
  static const Color darkBorder = Color(0xFF27272A); // Zinc 800
  static const Color darkInput = Color(0xFF27272A);
  static const Color darkRing = Color(0xFFD4D4D8);
}
