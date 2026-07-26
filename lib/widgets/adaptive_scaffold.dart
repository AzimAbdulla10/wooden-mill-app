import 'package:flutter/material.dart';
import 'package:wooden_mill_app/core/constants/app_constants.dart';
import 'package:wooden_mill_app/core/theme/shadcn_tokens.dart';
import 'package:wooden_mill_app/core/utils/responsive_layout.dart';
import 'package:wooden_mill_app/main.dart';

class AdaptiveScaffold extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<Widget> bodyPages;

  const AdaptiveScaffold({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.bodyPages,
  });

  @override
  State<AdaptiveScaffold> createState() => _AdaptiveScaffoldState();
}

class _AdaptiveScaffoldState extends State<AdaptiveScaffold> {
  DateTime? _lastBackPressTime;

  Future<bool> _handleRootBackPress() async {
    final now = DateTime.now();
    if (_lastBackPressTime == null || now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Back again to exit'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ShadTokens.radiusSm)),
        ),
      );
      return false; // Prevent exit
    }
    return true; // Allow exit on second press
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTabletOrDesktop = !ResponsiveLayout.isPhone(context);

    final Widget activeBody = widget.bodyPages.length == 1
        ? widget.bodyPages.first
        : IndexedStack(
            index: widget.selectedIndex,
            children: widget.bodyPages,
          );

    final scaffold = isTabletOrDesktop
        ? Scaffold(
            body: Row(
              children: [
                // Left Navigation Rail for Large Screens
                NavigationRail(
                  selectedIndex: widget.selectedIndex,
                  onDestinationSelected: widget.onDestinationSelected,
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: theme.colorScheme.surface,
                  indicatorColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: ShadTokens.spaceLg),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(ShadTokens.radiusSm),
                      child: Image.asset(
                        'assets/icon/app_icon.png',
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  trailing: Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: ShadTokens.spaceLg),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListenableBuilder(
                              listenable: themeController,
                              builder: (context, _) {
                                final isDark = Theme.of(context).brightness == Brightness.dark;
                                return IconButton(
                                  icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
                                  tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                                  onPressed: () => themeController.toggleTheme(context),
                                );
                              },
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppConstants.appVersionName,
                              style: TextStyle(
                                fontSize: 10,
                                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.calculate_outlined),
                      selectedIcon: Icon(Icons.calculate),
                      label: Text('Calculator'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.history_outlined),
                      selectedIcon: Icon(Icons.history),
                      label: Text('History'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings),
                      label: Text('Settings'),
                    ),
                  ],
                ),
                VerticalDivider(width: 1, thickness: 1, color: theme.colorScheme.outline),
                // Main Body Content
                Expanded(
                  child: activeBody,
                ),
              ],
            ),
          )
        : Scaffold(
            body: activeBody,
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: theme.colorScheme.outline, width: 1)),
              ),
              child: NavigationBar(
                selectedIndex: widget.selectedIndex,
                onDestinationSelected: widget.onDestinationSelected,
                backgroundColor: theme.colorScheme.surface,
                elevation: 0,
                indicatorColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.calculate_outlined),
                    selectedIcon: Icon(Icons.calculate),
                    label: 'Calculator',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.history_outlined),
                    selectedIcon: Icon(Icons.history),
                    label: 'History',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.settings_outlined),
                    selectedIcon: Icon(Icons.settings),
                    label: 'Settings',
                  ),
                ],
              ),
            ),
          );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _handleRootBackPress();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: scaffold,
    );
  }
}
