import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_image_widget.dart';

/// Widget that displays the QR code image with optimal contrast
class QRDisplayWidget extends StatelessWidget {
  final String qrImageUrl;
  final bool isGenerated;
  final String? qrData;
  final Color? qrColor;
  final Color? backgroundColor;
  final double? qrSize;
  final Uint8List? logoBytes;

  const QRDisplayWidget({
    super.key,
    required this.qrImageUrl,
    required this.isGenerated,
    this.qrData,
    this.qrColor,
    this.backgroundColor,
    this.qrSize,
    this.logoBytes,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasCustomization =
        qrColor != null || backgroundColor != null || logoBytes != null;

    return Container(
      width: 80.w,
      height: 80.w,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: hasCustomization && qrData != null
            ? QrImageView(
                data: qrData!,
                version: QrVersions.auto,
                size: 70.w,
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
                embeddedImage: logoBytes != null
                    ? MemoryImage(logoBytes!)
                    : null,
                embeddedImageStyle: logoBytes != null
                    ? QrEmbeddedImageStyle(size: Size(70.w * 0.2, 70.w * 0.2))
                    : null,
              )
            : CustomImageWidget(
                imageUrl: qrImageUrl,
                width: 70.w,
                height: 70.w,
                fit: BoxFit.contain,
                semanticLabel: isGenerated
                    ? "Generated QR code with black and white pattern on white background"
                    : "Scanned QR code image with encoded data pattern",
              ),
      ),
    );
  }
}
