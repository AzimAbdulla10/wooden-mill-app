import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget phone;
  final Widget tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.phone,
    required this.tablet,
    this.desktop,
  });

  static const double phoneBreakpoint = 600.0;
  static const double tabletBreakpoint = 1100.0;

  static bool isPhone(BuildContext context) =>
      MediaQuery.of(context).size.width < phoneBreakpoint;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= phoneBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= tabletBreakpoint && desktop != null) {
      return desktop!;
    }

    if (width >= phoneBreakpoint) {
      return tablet;
    }

    return phone;
  }
}
