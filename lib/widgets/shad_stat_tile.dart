import 'package:flutter/material.dart';
import 'package:wooden_mill_app/core/theme/shadcn_tokens.dart';

class ShadStatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final String? subtext;
  final bool isHighlight;

  const ShadStatTile({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.subtext,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.colorScheme.outline;

    return Container(
      padding: const EdgeInsets.all(ShadTokens.spaceMd),
      decoration: BoxDecoration(
        color: isHighlight
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.15)
            : theme.cardTheme.color,
        borderRadius: BorderRadius.circular(ShadTokens.radiusMd),
        border: Border.all(
          color: isHighlight ? theme.colorScheme.primary.withValues(alpha: 0.4) : borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (icon != null)
                Icon(
                  icon,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlight ? 20 : 18,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: isHighlight ? theme.colorScheme.primary : theme.colorScheme.onSurface,
            ),
          ),
          if (subtext != null) ...[
            const SizedBox(height: 4),
            Text(
              subtext!,
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
