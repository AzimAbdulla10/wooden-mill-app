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
    this.padding = const EdgeInsets.all(ShadTokens.spaceLg),
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.colorScheme.outline;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.cardTheme.color,
        borderRadius: BorderRadius.circular(ShadTokens.radiusMd),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null || description != null || action != null)
            Padding(
              padding: EdgeInsets.only(
                left: (padding as EdgeInsets).left,
                right: (padding as EdgeInsets).right,
                top: (padding as EdgeInsets).top,
                bottom: ShadTokens.spaceSm,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (title != null)
                          Text(
                            title!,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              letterSpacing: -0.2,
                            ),
                          ),
                        if (description != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            description!,
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 13,
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
                horizontal: (padding as EdgeInsets).left,
                vertical: ShadTokens.spaceMd,
              ),
              child: footer!,
            ),
          ],
        ],
      ),
    );
  }
}
