import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Primary action button for generating QR code
/// Disabled when input is empty, triggers haptic feedback on success
class GenerateButtonWidget extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onPressed;

  const GenerateButtonWidget({
    super.key,
    required this.isEnabled,
    required this.onPressed,
  });

  void _handlePress() {
    if (isEnabled) {
      HapticFeedback.mediumImpact();
      onPressed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 6.h,
      child: ElevatedButton(
        onPressed: isEnabled ? _handlePress : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          foregroundColor: Colors.white,
          disabledBackgroundColor: theme.colorScheme.onSurfaceVariant
              .withValues(alpha: 0.3),
          disabledForegroundColor: theme.colorScheme.onSurfaceVariant
              .withValues(alpha: 0.5),
          elevation: isEnabled ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3.w),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'qr_code_2',
              color: isEnabled
                  ? Colors.white
                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              size: 5.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'Generate QR Code',
              style: theme.textTheme.labelLarge?.copyWith(
                color: isEnabled
                    ? Colors.white
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
