import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget containing action buttons for QR result operations
class ActionButtonsWidget extends StatefulWidget {
  final String decodedText;
  final String qrImageUrl;
  final VoidCallback onSaveToHistory;

  const ActionButtonsWidget({
    super.key,
    required this.decodedText,
    required this.qrImageUrl,
    required this.onSaveToHistory,
  });

  @override
  State<ActionButtonsWidget> createState() => _ActionButtonsWidgetState();
}

class _ActionButtonsWidgetState extends State<ActionButtonsWidget> {
  bool _isSaved = false;

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: widget.decodedText));
    Fluttertoast.showToast(
      msg: "Copied!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black.withValues(alpha: 0.8),
      textColor: Colors.white,
      fontSize: 14.sp,
    );
  }

  Future<void> _shareQRCode() async {
    try {
      await Share.share(
        '${widget.decodedText}\n\nQR Code: ${widget.qrImageUrl}',
        subject: 'QR Code Content',
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to share",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        textColor: Colors.white,
        fontSize: 14.sp,
      );
    }
  }

  void _saveToHistory() {
    setState(() {
      _isSaved = true;
    });
    widget.onSaveToHistory();
    Fluttertoast.showToast(
      msg: "Saved to history",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green.withValues(alpha: 0.8),
      textColor: Colors.white,
      fontSize: 14.sp,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        _buildActionButton(
          context: context,
          icon: 'content_copy',
          label: 'Copy to Clipboard',
          onPressed: _copyToClipboard,
          theme: theme,
        ),
        SizedBox(height: 2.h),
        _buildActionButton(
          context: context,
          icon: 'share',
          label: 'Share QR Code',
          onPressed: _shareQRCode,
          theme: theme,
        ),
        SizedBox(height: 2.h),
        _buildActionButton(
          context: context,
          icon: _isSaved ? 'check' : 'bookmark_border',
          label: _isSaved ? 'Saved' : 'Save to History',
          onPressed: _isSaved ? null : _saveToHistory,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String icon,
    required String label,
    required VoidCallback? onPressed,
    required ThemeData theme,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 6.h,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: CustomIconWidget(
          iconName: icon,
          color: onPressed != null
              ? Colors.white
              : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.38),
          size: 20,
        ),
        label: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: onPressed != null
                ? Colors.white
                : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.38),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed != null
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          disabledBackgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
