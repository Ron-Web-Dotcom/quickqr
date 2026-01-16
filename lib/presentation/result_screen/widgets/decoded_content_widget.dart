import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Widget that displays decoded QR content in a scrollable container
class DecodedContentWidget extends StatelessWidget {
  final String decodedText;

  const DecodedContentWidget({super.key, required this.decodedText});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxHeight: 20.h, minHeight: 10.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline, width: 1),
      ),
      child: SingleChildScrollView(
        child: SelectableText(
          decodedText,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
