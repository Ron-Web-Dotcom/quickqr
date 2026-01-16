import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'dart:convert';
import 'dart:async';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/date_section_header.dart';
import './widgets/empty_history_widget.dart';
import './widgets/history_item_card.dart';

/// History Screen displays chronological list of all QR operations with management capabilities
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _historyItems = [];
  List<Map<String, dynamic>> _filteredItems = [];
  bool _isSelectionMode = false;
  final Set<int> _selectedIndices = {};
  Timer? _refreshTimer;
  String? _lastHistoryHash;
  bool _isLoadingHistory = false; // Prevent race conditions

  @override
  void initState() {
    super.initState();
    _loadHistoryData();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    // Check for updates every 2 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _checkForUpdates();
    });
  }

  Future<void> _checkForUpdates() async {
    // Prevent concurrent loading operations
    if (_isLoadingHistory) return;

    final prefs = await SharedPreferences.getInstance();
    final historyList = prefs.getStringList('qr_history') ?? [];
    final currentHash = historyList.join('|');

    if (_lastHistoryHash != currentHash) {
      _lastHistoryHash = currentHash;
      await _loadHistoryData();
    }
  }

  Future<void> _loadHistoryData() async {
    // Prevent race conditions with loading flag
    if (_isLoadingHistory) return;
    _isLoadingHistory = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final historyList = prefs.getStringList('qr_history') ?? [];

      final List<Map<String, dynamic>> loadedItems = [];

      for (int i = historyList.length - 1; i >= 0; i--) {
        try {
          final item = jsonDecode(historyList[i]) as Map<String, dynamic>;

          // Validate item structure to prevent corrupt data processing
          if (item['content'] == null || item['timestamp'] == null) {
            continue; // Skip invalid items
          }

          loadedItems.add({
            'id': i,
            'type': item['type'] ?? 'scan',
            'content': item['content'] ?? '',
            'timestamp': _formatTimestamp(item['timestamp']),
            'date': _formatDate(item['timestamp']),
            'thumbnailUrl':
                item['thumbnailUrl'] ??
                'https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=${Uri.encodeComponent(item['content'] ?? '')}',
            'rawTimestamp': item['timestamp'],
          });
        } catch (e) {
          // Log error and skip invalid items - implement data recovery
          debugPrint('Error parsing history item at index $i: $e');
          continue;
        }
      }

      if (mounted) {
        setState(() {
          _historyItems = loadedItems;
          _filteredItems = List.from(_historyItems);
        });
      }
    } finally {
      _isLoadingHistory = false;
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Unknown time';

    try {
      final DateTime dateTime = timestamp is String
          ? DateTime.parse(timestamp)
          : DateTime.fromMillisecondsSinceEpoch(timestamp as int);

      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
      } else {
        return '${(difference.inDays / 7).floor()} ${(difference.inDays / 7).floor() == 1 ? 'week' : 'weeks'} ago';
      }
    } catch (e) {
      return 'Unknown time';
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';

    try {
      final DateTime dateTime = timestamp is String
          ? DateTime.parse(timestamp)
          : DateTime.fromMillisecondsSinceEpoch(timestamp as int);

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final itemDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

      if (itemDate == today) {
        return 'Today';
      } else if (itemDate == yesterday) {
        return 'Yesterday';
      } else if (now.difference(dateTime).inDays < 7) {
        const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return weekdays[dateTime.weekday - 1];
      } else {
        const months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        return '${months[dateTime.month - 1]} ${dateTime.day}';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  void _filterHistory(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = List.from(_historyItems);
      } else {
        _filteredItems = _historyItems
            .where(
              (item) => (item['content'] as String).toLowerCase().contains(
                query.toLowerCase(),
              ),
            )
            .toList();
      }
    });
  }

  void _clearAllHistory() {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text('Clear All History', style: theme.textTheme.titleLarge),
          content: Text(
            'Are you sure you want to delete all QR codes from history? This action cannot be undone.',
            style: theme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('qr_history');
                setState(() {
                  _historyItems.clear();
                  _filteredItems.clear();
                });
                Fluttertoast.showToast(
                  msg: 'All history cleared',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
              ),
              child: Text(
                'Clear All',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteItem(int index) async {
    final item = _filteredItems[index];
    final prefs = await SharedPreferences.getInstance();
    final historyList = prefs.getStringList('qr_history') ?? [];

    // Find and remove the item from SharedPreferences
    historyList.removeWhere((historyItem) {
      try {
        final decoded = jsonDecode(historyItem) as Map<String, dynamic>;
        return decoded['content'] == item['content'] &&
            decoded['timestamp'] == item['rawTimestamp'];
      } catch (e) {
        return false;
      }
    });

    await prefs.setStringList('qr_history', historyList);

    setState(() {
      _historyItems.removeWhere((i) => i['id'] == item['id']);
      _filteredItems.removeAt(index);
    });
    Fluttertoast.showToast(
      msg: 'QR code deleted',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _shareItem(Map<String, dynamic> item) {
    Fluttertoast.showToast(
      msg: 'Sharing QR code...',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _copyItem(Map<String, dynamic> item) {
    Clipboard.setData(ClipboardData(text: item['content']));
    Fluttertoast.showToast(
      msg: 'Content copied to clipboard',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _viewDetails(Map<String, dynamic> item) {
    Navigator.of(context, rootNavigator: true).pushNamed(
      '/result-screen',
      arguments: {
        'qrData': item['content'] ?? '',
        'decodedText': item['content'] ?? '',
        'qrImageUrl':
            item['thumbnailUrl'] ??
            'https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=${Uri.encodeComponent(item['content'] ?? '')}',
        'isScanned': item['type'] == 'scanned',
      },
    );
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedIndices.clear();
      }
    });
  }

  void _deleteSelectedItems() {
    if (_selectedIndices.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text(
            'Delete Selected Items',
            style: theme.textTheme.titleLarge,
          ),
          content: Text(
            'Are you sure you want to delete ${_selectedIndices.length} selected item(s)?',
            style: theme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final prefs = await SharedPreferences.getInstance();
                final historyList = prefs.getStringList('qr_history') ?? [];

                // Get items to delete
                final itemsToDelete = _selectedIndices
                    .map((index) => _filteredItems[index])
                    .toList();

                // Remove from SharedPreferences
                historyList.removeWhere((historyItem) {
                  try {
                    final decoded =
                        jsonDecode(historyItem) as Map<String, dynamic>;
                    return itemsToDelete.any(
                      (item) =>
                          decoded['content'] == item['content'] &&
                          decoded['timestamp'] == item['rawTimestamp'],
                    );
                  } catch (e) {
                    return false;
                  }
                });

                await prefs.setStringList('qr_history', historyList);

                setState(() {
                  for (final item in itemsToDelete) {
                    _historyItems.removeWhere((i) => i['id'] == item['id']);
                    _filteredItems.removeWhere((i) => i['id'] == item['id']);
                  }
                  _selectedIndices.clear();
                  _isSelectionMode = false;
                });

                Fluttertoast.showToast(
                  msg: '${itemsToDelete.length} item(s) deleted',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
              ),
              child: Text(
                'Delete',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Map<String, List<Map<String, dynamic>>> _groupItemsByDate() {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var item in _filteredItems) {
      final date = item['date'] as String;
      grouped.putIfAbsent(date, () => []).add(item);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groupedItems = _groupItemsByDate();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: theme.colorScheme.onSurface,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: _isSelectionMode
            ? Text(
                '${_selectedIndices.length} selected',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              )
            : Text(
                'History',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
        actions: [
          if (_isSelectionMode)
            IconButton(
              icon: CustomIconWidget(
                iconName: 'delete',
                color: theme.colorScheme.error,
                size: 24,
              ),
              onPressed: _deleteSelectedItems,
            )
          else if (_historyItems.isNotEmpty) ...[
            IconButton(
              icon: CustomIconWidget(
                iconName: 'checklist',
                color: theme.colorScheme.onSurface,
                size: 24,
              ),
              onPressed: _toggleSelectionMode,
            ),
            IconButton(
              icon: CustomIconWidget(
                iconName: 'delete_sweep',
                color: theme.colorScheme.onSurface,
                size: 24,
              ),
              onPressed: _clearAllHistory,
            ),
          ],
        ],
      ),
      body: _historyItems.isEmpty
          ? EmptyHistoryWidget(
              onStartScanning: () {
                Navigator.of(
                  context,
                  rootNavigator: true,
                ).pushNamed('/scan-screen');
              },
            )
          : Column(
              children: [
                // Search bar
                Container(
                  padding: EdgeInsets.all(4.w),
                  color: theme.colorScheme.surface,
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterHistory,
                    decoration: InputDecoration(
                      hintText: 'Search history...',
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(3.w),
                        child: CustomIconWidget(
                          iconName: 'search',
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: CustomIconWidget(
                                iconName: 'clear',
                                color: theme.colorScheme.onSurfaceVariant,
                                size: 20,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _filterHistory('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outline,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outline,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                // History list
                Expanded(
                  child: _filteredItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomIconWidget(
                                iconName: 'search_off',
                                color: theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.5),
                                size: 64,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'No results found',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            await Future.delayed(
                              const Duration(milliseconds: 500),
                            );
                            _loadHistoryData();
                          },
                          child: ListView.builder(
                            padding: EdgeInsets.only(bottom: 2.h),
                            itemCount: groupedItems.length,
                            itemBuilder: (context, sectionIndex) {
                              final dateLabel = groupedItems.keys.elementAt(
                                sectionIndex,
                              );
                              final items = groupedItems[dateLabel]!;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  DateSectionHeader(dateLabel: dateLabel),
                                  ...items.asMap().entries.map((entry) {
                                    final itemIndex = _filteredItems.indexWhere(
                                      (item) => item['id'] == entry.value['id'],
                                    );
                                    final isSelected = _selectedIndices
                                        .contains(itemIndex);

                                    return Slidable(
                                      key: ValueKey(entry.value['id']),
                                      startActionPane: ActionPane(
                                        motion: const ScrollMotion(),
                                        children: [
                                          SlidableAction(
                                            onPressed: (_) =>
                                                _shareItem(entry.value),
                                            backgroundColor:
                                                theme.colorScheme.primary,
                                            foregroundColor: Colors.white,
                                            icon: Icons.share,
                                            label: 'Share',
                                          ),
                                          SlidableAction(
                                            onPressed: (_) =>
                                                _copyItem(entry.value),
                                            backgroundColor:
                                                theme.colorScheme.tertiary,
                                            foregroundColor: Colors.white,
                                            icon: Icons.content_copy,
                                            label: 'Copy',
                                          ),
                                        ],
                                      ),
                                      endActionPane: ActionPane(
                                        motion: const ScrollMotion(),
                                        children: [
                                          SlidableAction(
                                            onPressed: (_) =>
                                                _deleteItem(itemIndex),
                                            backgroundColor:
                                                theme.colorScheme.error,
                                            foregroundColor: Colors.white,
                                            icon: Icons.delete,
                                            label: 'Delete',
                                          ),
                                        ],
                                      ),
                                      child: _isSelectionMode
                                          ? InkWell(
                                              onTap: () {
                                                setState(() {
                                                  if (isSelected) {
                                                    _selectedIndices.remove(
                                                      itemIndex,
                                                    );
                                                  } else {
                                                    _selectedIndices.add(
                                                      itemIndex,
                                                    );
                                                  }
                                                });
                                              },
                                              child: Container(
                                                color: isSelected
                                                    ? theme.colorScheme.primary
                                                          .withValues(
                                                            alpha: 0.1,
                                                          )
                                                    : Colors.transparent,
                                                child: Row(
                                                  children: [
                                                    Checkbox(
                                                      value: isSelected,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          if (value == true) {
                                                            _selectedIndices
                                                                .add(itemIndex);
                                                          } else {
                                                            _selectedIndices
                                                                .remove(
                                                                  itemIndex,
                                                                );
                                                          }
                                                        });
                                                      },
                                                    ),
                                                    Expanded(
                                                      child: HistoryItemCard(
                                                        item: entry.value,
                                                        onTap: () =>
                                                            setState(() {
                                                              if (isSelected) {
                                                                _selectedIndices
                                                                    .remove(
                                                                      itemIndex,
                                                                    );
                                                              } else {
                                                                _selectedIndices
                                                                    .add(
                                                                      itemIndex,
                                                                    );
                                                              }
                                                            }),
                                                        onShare: () =>
                                                            _shareItem(
                                                              entry.value,
                                                            ),
                                                        onCopy: () => _copyItem(
                                                          entry.value,
                                                        ),
                                                        onDelete: () =>
                                                            _deleteItem(
                                                              itemIndex,
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : HistoryItemCard(
                                              item: entry.value,
                                              onTap: () =>
                                                  _viewDetails(entry.value),
                                              onShare: () =>
                                                  _shareItem(entry.value),
                                              onCopy: () =>
                                                  _copyItem(entry.value),
                                              onDelete: () =>
                                                  _deleteItem(itemIndex),
                                            ),
                                    );
                                  }),
                                ],
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
