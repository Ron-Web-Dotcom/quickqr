import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget that provides content-type specific actions (URL, phone, email)
class ContentTypeActionsWidget extends StatelessWidget {
  final String decodedText;

  const ContentTypeActionsWidget({super.key, required this.decodedText});

  bool _isUrl() {
    return Uri.tryParse(decodedText)?.hasScheme ?? false;
  }

  bool _isPhoneNumber() {
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]+$');
    return phoneRegex.hasMatch(decodedText.trim()) &&
        decodedText.trim().length >= 10;
  }

  bool _isEmail() {
    final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');
    return emailRegex.hasMatch(decodedText.trim());
  }

  Future<void> _openUrl(BuildContext context) async {
    final uri = Uri.parse(decodedText);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Fluttertoast.showToast(
        msg: "Cannot open URL",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        textColor: Colors.white,
        fontSize: 14.sp,
      );
    }
  }

  Future<void> _makeCall(BuildContext context) async {
    final uri = Uri.parse('tel:${decodedText.trim()}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Fluttertoast.showToast(
        msg: "Cannot make call",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        textColor: Colors.white,
        fontSize: 14.sp,
      );
    }
  }

  Future<void> _sendEmail(BuildContext context) async {
    final uri = Uri.parse('mailto:${decodedText.trim()}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Fluttertoast.showToast(
        msg: "Cannot send email",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        textColor: Colors.white,
        fontSize: 14.sp,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isUrl()) {
      return _buildActionButton(
        context: context,
        icon: 'open_in_new',
        label: 'Open Link',
        onPressed: () => _openUrl(context),
        theme: theme,
      );
    } else if (_isPhoneNumber()) {
      return _buildActionButton(
        context: context,
        icon: 'phone',
        label: 'Call',
        onPressed: () => _makeCall(context),
        theme: theme,
      );
    } else if (_isEmail()) {
      return _buildActionButton(
        context: context,
        icon: 'email',
        label: 'Send Email',
        onPressed: () => _sendEmail(context),
        theme: theme,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String icon,
    required String label,
    required VoidCallback onPressed,
    required ThemeData theme,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 6.h,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: CustomIconWidget(
          iconName: icon,
          color: theme.colorScheme.primary,
          size: 20,
        ),
        label: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: theme.colorScheme.primary, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
