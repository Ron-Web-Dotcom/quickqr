import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Expandable privacy information widget
class PrivacyExpandableWidget extends StatefulWidget {
  const PrivacyExpandableWidget({super.key});

  @override
  State<PrivacyExpandableWidget> createState() =>
      _PrivacyExpandableWidgetState();
}

class _PrivacyExpandableWidgetState extends State<PrivacyExpandableWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'shield',
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your data stays on device',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Learn More',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CustomIconWidget(
                    iconName: _isExpanded ? 'expand_less' : 'expand_more',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: EdgeInsets.fromLTRB(56, 0, 16, 16),
              child: Text(
                'QuickQR is designed with privacy as a core principle. All your QR code scans and generations are stored locally on your device. We do not collect, transmit, or store any of your data on external servers. Your information never leaves your device, ensuring complete privacy and security. The app works entirely offline, requiring no internet connection for core functionality.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
