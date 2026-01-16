import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Individual history item card widget displaying QR operation details
class HistoryItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;
  final VoidCallback onShare;
  final VoidCallback onCopy;
  final VoidCallback onDelete;

  const HistoryItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onShare,
    required this.onCopy,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isScanned = item['type'] == 'scan';
    final String content = item['content'] ?? '';
    final String timestamp = item['timestamp'] ?? '';
    final String thumbnailUrl = item['thumbnailUrl'] ?? '';

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        onLongPress: () => _showContextMenu(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(3.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type indicator icon
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: isScanned
                      ? theme.colorScheme.primary.withValues(alpha: 0.1)
                      : theme.colorScheme.tertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: isScanned ? 'qr_code_scanner' : 'qr_code_2',
                    color: isScanned
                        ? theme.colorScheme.primary
                        : theme.colorScheme.tertiary,
                    size: 24,
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              // Content and timestamp
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isScanned ? 'Scanned QR Code' : 'Generated QR Code',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      content.length > 50
                          ? '${content.substring(0, 50)}...'
                          : content,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'access_time',
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.6,
                          ),
                          size: 14,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          timestamp,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 2.w),
              // QR thumbnail
              if (thumbnailUrl.isNotEmpty)
                Container(
                  width: 15.w,
                  height: 15.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CustomImageWidget(
                      imageUrl: thumbnailUrl,
                      width: 15.w,
                      height: 15.w,
                      fit: BoxFit.cover,
                      semanticLabel:
                          'QR code thumbnail for ${isScanned ? 'scanned' : 'generated'} content',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'visibility',
                color: theme.colorScheme.onSurface,
                size: 24,
              ),
              title: Text('View Details', style: theme.textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                onTap();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'share',
                color: theme.colorScheme.onSurface,
                size: 24,
              ),
              title: Text('Share', style: theme.textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                onShare();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'content_copy',
                color: theme.colorScheme.onSurface,
                size: 24,
              ),
              title: Text('Copy', style: theme.textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                onCopy();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'delete',
                color: theme.colorScheme.error,
                size: 24,
              ),
              title: Text(
                'Delete',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete QR Code', style: theme.textTheme.titleLarge),
        content: Text(
          'Are you sure you want to delete this QR code from history?',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: Text(
              'Delete',
              style: theme.textTheme.labelLarge?.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
