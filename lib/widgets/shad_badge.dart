import 'package:flutter/material.dart';
import 'package:wooden_mill_app/core/theme/shadcn_tokens.dart';

enum ShadBadgeVariant {
  defaultVariant,
  secondary,
  outline,
  destructive,
}

class ShadBadge extends StatelessWidget {
  final String label;
  final ShadBadgeVariant variant;
  final IconData? icon;

  const ShadBadge({
    super.key,
    required this.label,
    this.variant = ShadBadgeVariant.defaultVariant,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color bg;
    Color fg;
    Border? border;

    switch (variant) {
      case ShadBadgeVariant.secondary:
        bg = theme.colorScheme.secondary;
        fg = theme.colorScheme.onSecondary;
        border = null;
        break;
      case ShadBadgeVariant.outline:
        bg = Colors.transparent;
        fg = theme.colorScheme.onSurface;
        border = Border.all(color: theme.colorScheme.outline, width: 1);
        break;
      case ShadBadgeVariant.destructive:
        bg = theme.colorScheme.error;
        fg = theme.colorScheme.onError;
        border = null;
        break;
      case ShadBadgeVariant.defaultVariant:
        bg = theme.colorScheme.primary;
        fg = theme.colorScheme.onPrimary;
        border = null;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(ShadTokens.radiusSm),
        border: border,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: fg,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}
