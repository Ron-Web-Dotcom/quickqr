import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class HistoryItemWidget extends StatelessWidget {
  final String type;
  final String content;
  final String preview;
  final DateTime timestamp;
  final VoidCallback onTap;

  const HistoryItemWidget({
    super.key,
    required this.type,
    required this.content,
    required this.preview,
    required this.timestamp,
    required this.onTap,
  });

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.month}/${timestamp.day}/${timestamp.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isScanned = type == 'scanned';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.5.w),
              decoration: BoxDecoration(
                color: isScanned
                    ? theme.colorScheme.tertiaryContainer
                    : theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: CustomIconWidget(
                iconName: isScanned ? 'qr_code_scanner' : 'qr_code_2',
                color: isScanned
                    ? theme.colorScheme.tertiary
                    : theme.colorScheme.primary,
                size: 24,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 0.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: isScanned
                              ? theme.colorScheme.tertiaryContainer
                              : theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isScanned ? 'Scanned' : 'Generated',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isScanned
                                ? theme.colorScheme.tertiary
                                : theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        _formatTimestamp(timestamp),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    preview,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'chevron_right',
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
