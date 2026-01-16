import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'dart:convert';
import 'dart:async';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/action_button_widget.dart';
import './widgets/history_item_widget.dart';

class HomeScreenInitialPage extends StatefulWidget {
  const HomeScreenInitialPage({super.key});

  @override
  State<HomeScreenInitialPage> createState() => _HomeScreenInitialPageState();
}

class _HomeScreenInitialPageState extends State<HomeScreenInitialPage> {
  List<Map<String, dynamic>> recentHistory = [];
  Timer? _refreshTimer;
  String? _lastHistoryHash;

  @override
  void initState() {
    super.initState();
    _loadRecentHistory();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _checkForUpdates();
    });
  }

  Future<void> _checkForUpdates() async {
    final prefs = await SharedPreferences.getInstance();
    final historyList = prefs.getStringList('qr_history') ?? [];
    final currentHash = historyList.join('|');

    if (_lastHistoryHash != currentHash) {
      _lastHistoryHash = currentHash;
      await _loadRecentHistory();
    }
  }

  Future<void> _loadRecentHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyList = prefs.getStringList('qr_history') ?? [];

    final List<Map<String, dynamic>> loadedItems = [];

    for (int i = 0; i < historyList.length && i < 3; i++) {
      try {
        final item = jsonDecode(historyList[i]) as Map<String, dynamic>;
        final content = item['content'] ?? '';
        final type = item['type'] ?? 'scan';
        final timestamp = item['timestamp'];

        DateTime parsedTimestamp;
        if (timestamp is String) {
          parsedTimestamp = DateTime.parse(timestamp);
        } else if (timestamp is int) {
          parsedTimestamp = DateTime.fromMillisecondsSinceEpoch(timestamp);
        } else {
          parsedTimestamp = DateTime.now();
        }

        loadedItems.add({
          'id': i,
          'type': type,
          'content': content,
          'timestamp': parsedTimestamp,
          'preview': _generatePreview(content),
        });
      } catch (e) {
        continue;
      }
    }

    if (mounted) {
      setState(() {
        recentHistory = loadedItems;
      });
    }
  }

  String _generatePreview(String content) {
    if (content.startsWith('http://') || content.startsWith('https://')) {
      try {
        final uri = Uri.parse(content);
        return 'Link - ${uri.host}';
      } catch (e) {
        return 'URL Link';
      }
    } else if (content.startsWith('WiFi:')) {
      final ssidMatch = RegExp(r'S:([^;]+)').firstMatch(content);
      if (ssidMatch != null) {
        return 'WiFi Network - ${ssidMatch.group(1)}';
      }
      return 'WiFi Network';
    } else if (content.contains('@') && content.contains('.')) {
      return 'Email - ${content.split('@').first}';
    } else if (content.startsWith('tel:') || content.startsWith('+')) {
      return 'Phone Number';
    } else if (content.length > 50) {
      return '${content.substring(0, 50)}...';
    }
    return content;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        children: [
          _buildAppBar(context, theme),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 4.h),
                    _buildHeader(theme),
                    SizedBox(height: 6.h),
                    _buildActionButtons(context),
                    SizedBox(height: 6.h),
                    _buildRecentHistory(context, theme),
                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'QuickQR',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                'Secure & Offline',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/settings-screen');
            },
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomIconWidget(
                iconName: 'settings',
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: CustomIconWidget(
            iconName: 'qr_code_2',
            color: theme.colorScheme.primary,
            size: 48,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          'Quick QR Operations',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Scan or generate QR codes instantly',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        ActionButtonWidget(
          icon: 'qr_code_scanner',
          title: 'Scan QR Code',
          subtitle: 'Use camera to scan',
          onTap: () {
            Navigator.pushNamed(context, '/scan-screen');
          },
        ),
        SizedBox(height: 2.h),
        ActionButtonWidget(
          icon: 'add_circle_outline',
          title: 'Generate QR Code',
          subtitle: 'Create from text',
          onTap: () {
            Navigator.pushNamed(context, '/generate-screen');
          },
        ),
      ],
    );
  }

  Widget _buildRecentHistory(BuildContext context, ThemeData theme) {
    if (recentHistory.isEmpty) {
      return _buildEmptyState(theme);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent History',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/history-screen');
              },
              child: Text(
                'View All',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentHistory.length > 3 ? 3 : recentHistory.length,
          separatorBuilder: (context, index) => SizedBox(height: 1.5.h),
          itemBuilder: (context, index) {
            final item = recentHistory[index];
            return HistoryItemWidget(
              type: item["type"] as String,
              content: item["content"] as String,
              preview: item["preview"] as String,
              timestamp: item["timestamp"] as DateTime,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/result-screen',
                  arguments: {
                    'qrData': item["content"],
                    'decodedText': item["content"],
                    'type': item["type"],
                    'isGenerated': item["type"] == 'generated',
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 4.w),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'history',
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            'No History Yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Scan or generate your first QR code',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
