import 'package:flutter/material.dart';
import 'package:wooden_mill_app/core/theme/shadcn_tokens.dart';

class ShadCard extends StatelessWidget {
  final String? title;
  final String? description;
  final Widget? action;
  final Widget child;
  final Widget? footer;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;

  const ShadCard({
    super.key,
    this.title,
    this.description,
    this.action,
    required this.child,
    this.footer,
    this.padding = const EdgeInsets.all(12.0),
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.colorScheme.outlineVariant.withValues(alpha: 0.3);

    final edgePadding = padding is EdgeInsets ? (padding as EdgeInsets) : const EdgeInsets.all(12.0);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(ShadTokens.radiusMd),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null || description != null || action != null)
            Padding(
              padding: EdgeInsets.only(
                left: edgePadding.left,
                right: edgePadding.right,
                top: edgePadding.top,
                bottom: 4.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (title != null)
                          Text(
                            title!,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              letterSpacing: -0.1,
                            ),
                          ),
                        if (description != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            description!,
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  ?action,
                ],
              ),
            ),
          Padding(
            padding: padding,
            child: child,
          ),
          if (footer != null) ...[
            Divider(color: borderColor, height: 1),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: edgePadding.left,
                vertical: ShadTokens.spaceSm,
              ),
              child: footer!,
            ),
          ],
        ],
      ),
    );
  }
}
