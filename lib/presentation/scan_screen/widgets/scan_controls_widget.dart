import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Top control bar with back button and flashlight toggle
class ScanControlsWidget extends StatelessWidget {
  final bool isFlashOn;
  final VoidCallback onBackPressed;
  final VoidCallback onFlashToggle;

  const ScanControlsWidget({
    super.key,
    required this.isFlashOn,
    required this.onBackPressed,
    required this.onFlashToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onBackPressed,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: CustomIconWidget(
                  iconName: 'arrow_back',
                  size: 24,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Flash toggle button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onFlashToggle,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isFlashOn
                      ? theme.colorScheme.primary.withValues(alpha: 0.9)
                      : Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: CustomIconWidget(
                  iconName: isFlashOn ? 'flash_on' : 'flash_off',
                  size: 24,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
