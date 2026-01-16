import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Date section header widget for grouping history items by date
class DateSectionHeader extends StatelessWidget {
  final String dateLabel;

  const DateSectionHeader({super.key, required this.dateLabel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      color: theme.colorScheme.surface,
      child: Text(
        dateLabel,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
