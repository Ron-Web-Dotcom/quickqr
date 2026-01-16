import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Empty state widget displayed when no history items exist
class EmptyHistoryWidget extends StatelessWidget {
  final VoidCallback onStartScanning;

  const EmptyHistoryWidget({super.key, required this.onStartScanning});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty state illustration
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'qr_code_scanner',
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                  size: 80,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            // Empty state title
            Text(
              'No QR Codes Yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            // Empty state description
            Text(
              'Your scanned and generated QR codes will appear here',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            // Call-to-action button
            ElevatedButton.icon(
              onPressed: onStartScanning,
              icon: CustomIconWidget(
                iconName: 'qr_code_scanner',
                color: Colors.white,
                size: 20,
              ),
              label: Text(
                'Start Scanning',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
