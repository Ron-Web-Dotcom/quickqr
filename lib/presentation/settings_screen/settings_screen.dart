import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/privacy_expandable_widget.dart';
import './widgets/settings_item_widget.dart';
import './widgets/settings_section_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  String _appVersion = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadAppInfo();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _loadAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    setState(() => _isDarkMode = value);

    Fluttertoast.showToast(
      msg: value ? 'Dark mode enabled' : 'Light mode enabled',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  Future<void> _showClearHistoryDialog() async {
    final theme = Theme.of(context);

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              CustomIconWidget(
                iconName: 'warning',
                color: theme.colorScheme.error,
                size: 24,
              ),
              SizedBox(width: 12),
              Text('Clear All History?'),
            ],
          ),
          content: Text(
            'This will permanently delete all your scanned and generated QR codes. This action cannot be undone.',
            style: theme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _clearHistory();
                if (mounted) Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
              ),
              child: Text('Clear All'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('qr_history');

    Fluttertoast.showToast(
      msg: 'History cleared successfully',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _showPrivacyPolicy() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Privacy Policy'),
          content: SingleChildScrollView(
            child: Text(
              'QuickQR Privacy Policy\n\nLast Updated: January 13, 2026\n\n1. Data Collection\nQuickQR does not collect, transmit, or store any personal data on external servers. All QR code scans and generations are stored locally on your device.\n\n2. Permissions\nCamera: Required for scanning QR codes\nStorage: Required for saving QR code history locally\n\n3. Data Storage\nAll data is stored locally using device storage. No cloud synchronization or external data transmission occurs.\n\n4. Third-Party Services\nQuickQR does not integrate with any third-party analytics, advertising, or tracking services.\n\n5. Data Security\nYour data remains on your device and is protected by your device\'s security measures.\n\n6. Changes to Policy\nAny updates to this privacy policy will be reflected in app updates.\n\n7. Contact\nFor privacy concerns, please contact us through the app store listing.',
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _rateApp() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final packageName = packageInfo.packageName;

      Uri appStoreUrl;

      if (Platform.isAndroid) {
        appStoreUrl = Uri.parse(
          'https://play.google.com/store/apps/details?id=$packageName',
        );
      } else if (Platform.isIOS) {
        appStoreUrl = Uri.parse('https://apps.apple.com/app/id$packageName');
      } else {
        Fluttertoast.showToast(
          msg: 'Rating not available on this platform',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        return;
      }

      if (await canLaunchUrl(appStoreUrl)) {
        await launchUrl(appStoreUrl, mode: LaunchMode.externalApplication);
      } else {
        Fluttertoast.showToast(
          msg: 'Could not open app store',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error opening app store',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _shareApp() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final packageName = packageInfo.packageName;
      final appName = packageInfo.appName;

      String shareText;

      if (Platform.isAndroid) {
        shareText =
            'Check out $appName - A privacy-focused QR code scanner and generator!\n\nhttps://play.google.com/store/apps/details?id=$packageName';
      } else if (Platform.isIOS) {
        shareText =
            'Check out $appName - A privacy-focused QR code scanner and generator!\n\nhttps://apps.apple.com/app/id$packageName';
      } else {
        shareText =
            'Check out $appName - A privacy-focused QR code scanner and generator!';
      }

      final result = await Share.share(shareText, subject: 'Try $appName');

      // Handle share result
      if (result.status == ShareResultStatus.success) {
        Fluttertoast.showToast(
          msg: 'Thanks for sharing!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      } else if (result.status == ShareResultStatus.dismissed) {
        // User dismissed the share dialog - no action needed
      } else if (result.status == ShareResultStatus.unavailable) {
        Fluttertoast.showToast(
          msg: 'Sharing is not available on this device',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error sharing the app: ${e.toString()}',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _reportIssue() async {
    final theme = Theme.of(context);

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final appName = packageInfo.appName;
      final appVersion = packageInfo.version;
      final buildNumber = packageInfo.buildNumber;

      final emailUri = Uri(
        scheme: 'mailto',
        path: 'support@quickqr.app',
        query:
            'subject=Issue Report - $appName v$appVersion ($buildNumber)&body=Please describe the issue you encountered:\n\n',
      );

      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        // Fallback to dialog if email client not available
        if (mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Report an Issue'),
                content: Text(
                  'Thank you for helping us improve QuickQR!\n\nPlease email your issue report to:\nsupport@quickqr.app\n\nInclude:\n- App version: $appVersion ($buildNumber)\n- Device: ${Platform.operatingSystem}\n- Description of the issue',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Close'),
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error opening email client',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Settings'),
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: theme.colorScheme.onSurface,
            size: 24,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            SettingsSectionWidget(
              title: 'APPEARANCE',
              items: [
                SettingsItemWidget(
                  iconName: _isDarkMode ? 'dark_mode' : 'light_mode',
                  title: 'Dark Mode',
                  subtitle: _isDarkMode ? 'Enabled' : 'Disabled',
                  trailing: Switch(
                    value: _isDarkMode,
                    onChanged: _toggleDarkMode,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            SettingsSectionWidget(
              title: 'DATA MANAGEMENT',
              items: [
                SettingsItemWidget(
                  iconName: 'delete_sweep',
                  title: 'Clear All History',
                  subtitle: 'Delete all scanned and generated QR codes',
                  isDestructive: true,
                  trailing: CustomIconWidget(
                    iconName: 'chevron_right',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                  onTap: _showClearHistoryDialog,
                ),
              ],
            ),
            SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'PRIVACY',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                PrivacyExpandableWidget(),
              ],
            ),
            SizedBox(height: 24),
            SettingsSectionWidget(
              title: 'SUPPORT',
              items: [
                SettingsItemWidget(
                  iconName: 'star',
                  title: 'Rate the App',
                  subtitle: 'Share your feedback',
                  trailing: CustomIconWidget(
                    iconName: 'chevron_right',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                  onTap: _rateApp,
                ),
                SettingsItemWidget(
                  iconName: 'share',
                  title: 'Share with Friends',
                  subtitle: 'Recommend QuickQR',
                  trailing: CustomIconWidget(
                    iconName: 'chevron_right',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                  onTap: _shareApp,
                ),
                SettingsItemWidget(
                  iconName: 'bug_report',
                  title: 'Report an Issue',
                  subtitle: 'Help us improve',
                  trailing: CustomIconWidget(
                    iconName: 'chevron_right',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                  onTap: _reportIssue,
                ),
              ],
            ),
            SizedBox(height: 32),
            Center(
              child: Text(
                'QuickQR © 2026\nPrivacy-focused QR solution',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
