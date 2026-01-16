import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget for customizing QR code appearance
/// Provides color picker, logo insertion, and size options
class QrCustomizationWidget extends StatelessWidget {
  final Color qrColor;
  final Color backgroundColor;
  final double qrSize;
  final dynamic logoImage;
  final VoidCallback onColorPickerTap;
  final VoidCallback onBackgroundColorPickerTap;
  final ValueChanged<double> onSizeChanged;
  final VoidCallback onLogoPickerTap;
  final VoidCallback? onLogoRemove;

  const QrCustomizationWidget({
    super.key,
    required this.qrColor,
    required this.backgroundColor,
    required this.qrSize,
    this.logoImage,
    required this.onColorPickerTap,
    required this.onBackgroundColorPickerTap,
    required this.onSizeChanged,
    required this.onLogoPickerTap,
    this.onLogoRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customize QR Code',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildColorOption(
                  context,
                  'QR Color',
                  qrColor,
                  onColorPickerTap,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildColorOption(
                  context,
                  'Background',
                  backgroundColor,
                  onBackgroundColorPickerTap,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Size: ${qrSize.toInt()}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Slider(
            value: qrSize,
            min: 200,
            max: 500,
            divisions: 30,
            label: qrSize.toInt().toString(),
            onChanged: onSizeChanged,
            activeColor: theme.colorScheme.primary,
          ),
          SizedBox(height: 1.h),
          _buildLogoOption(context),
        ],
      ),
    );
  }

  Widget _buildColorOption(
    BuildContext context,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4.0),
                border: Border.all(color: theme.colorScheme.outline, width: 1),
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoOption(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onLogoPickerTap,
      child: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(4.0),
                border: Border.all(color: theme.colorScheme.outline, width: 1),
              ),
              child: logoImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: kIsWeb
                          ? Image.memory(
                              logoImage as Uint8List,
                              fit: BoxFit.cover,
                            )
                          : Image.file(logoImage as File, fit: BoxFit.cover),
                    )
                  : Center(
                      child: CustomIconWidget(
                        iconName: 'add_photo_alternate',
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 6.w,
                      ),
                    ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                logoImage != null ? 'Change Logo' : 'Add Logo (Optional)',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            if (logoImage != null && onLogoRemove != null)
              IconButton(
                icon: CustomIconWidget(
                  iconName: 'close',
                  color: theme.colorScheme.error,
                  size: 5.w,
                ),
                onPressed: onLogoRemove,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }
}
