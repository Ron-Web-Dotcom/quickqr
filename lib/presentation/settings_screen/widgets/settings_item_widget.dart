import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Individual settings item with icon, title, subtitle and trailing widget
class SettingsItemWidget extends StatelessWidget {
  final String iconName;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;

  const SettingsItemWidget({
    super.key,
    required this.iconName,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: isDestructive
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
              size: 24,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isDestructive
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[SizedBox(width: 8), trailing!],
          ],
        ),
      ),
    );
  }
}
