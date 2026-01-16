import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget that displays a live preview of the generated QR code
/// Updates instantly as user types in the input field
class QrPreviewWidget extends StatelessWidget {
  final String qrData;
  final bool isDarkMode;
  final Color? qrColor;
  final Color? backgroundColor;
  final double? size;
  final dynamic embeddedImage;

  const QrPreviewWidget({
    super.key,
    required this.qrData,
    required this.isDarkMode,
    this.qrColor,
    this.backgroundColor,
    this.size,
    this.embeddedImage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displaySize = size ?? 80.w;

    return Container(
      width: displaySize,
      height: displaySize,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: qrData.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'qr_code_2',
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.3,
                    ),
                    size: 15.w,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'QR code preview',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Start typing to see preview',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.4,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: displaySize * 0.9,
              backgroundColor: backgroundColor ?? Colors.white,
              errorCorrectionLevel: QrErrorCorrectLevel.H,
              padding: EdgeInsets.all(2.w),
              eyeStyle: QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: qrColor ?? Colors.black,
              ),
              dataModuleStyle: QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: qrColor ?? Colors.black,
              ),
              embeddedImage: embeddedImage != null
                  ? (kIsWeb
                            ? MemoryImage(embeddedImage as Uint8List)
                            : FileImage(embeddedImage as File))
                        as ImageProvider
                  : null,
              embeddedImageStyle: embeddedImage != null
                  ? QrEmbeddedImageStyle(
                      size: Size(displaySize * 0.2, displaySize * 0.2),
                    )
                  : null,
            ),
    );
  }
}
