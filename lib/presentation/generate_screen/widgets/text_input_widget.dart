import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget for text input with character counter and validation
/// Supports URL detection for appropriate keyboard type
class TextInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final String? errorText;

  const TextInputWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    this.errorText,
  });

  bool _isUrl(String text) {
    final urlPattern = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
      caseSensitive: false,
    );
    return urlPattern.hasMatch(text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUrl = _isUrl(controller.text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(minHeight: 20.h, maxHeight: 30.h),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            maxLines: null,
            keyboardType: isUrl ? TextInputType.url : TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: 'Enter text or URL',
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.5,
                ),
              ),
              errorText: errorText,
              filled: true,
              fillColor: theme.colorScheme.surface,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 4.w,
                vertical: 2.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(3.w),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(3.w),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(3.w),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 1,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(3.w),
                borderSide: BorderSide(
                  color: theme.colorScheme.error,
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(3.w),
                borderSide: BorderSide(
                  color: theme.colorScheme.error,
                  width: 1,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 1.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isUrl)
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'link',
                      color: theme.colorScheme.primary,
                      size: 4.w,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'URL detected',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                )
              else
                const SizedBox.shrink(),
              Text(
                '${controller.text.length} characters',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.7,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
