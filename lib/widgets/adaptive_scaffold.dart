import 'package:flutter/material.dart';
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

    if (isTabletOrDesktop) {
      return Scaffold(
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
                    child: ListenableBuilder(
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
              ],
            ),
            VerticalDivider(width: 1, thickness: 1, color: theme.colorScheme.outline),
            // Main Body Content
            Expanded(
              child: activeBody,
            ),
          ],
        ),
      );
    }

    // Mobile Viewport with Bottom Navigation Bar
    return Scaffold(
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
          ],
        ),
      ),
    );
  }
}
