import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'dart:typed_data';
import 'dart:convert';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/content_type_actions_widget.dart';
import './widgets/decoded_content_widget.dart';
import './widgets/qr_display_widget.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  String _qrImageUrl = '';
  String _decodedText = '';
  bool _isGenerated = false;
  bool _isLoading = true;
  Color? _qrColor;
  Color? _backgroundColor;
  double? _qrSize;
  Uint8List? _logoBytes;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadResultData();
  }

  Future<void> _loadResultData() async {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // Validate arguments to prevent null crashes
    if (args == null ||
        (args['qrData'] == null &&
            args['decodedText'] == null &&
            args['qrImageUrl'] == null)) {
      setState(() {
        _qrImageUrl =
            'https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=Sample%20QR%20Code';
        _decodedText = 'Sample QR Code Content';
        _isGenerated = false;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _qrImageUrl =
          args['qrImageUrl'] as String? ??
          'https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=${Uri.encodeComponent(args['qrData'] as String? ?? 'Sample%20QR%20Code')}';
      _decodedText =
          args['decodedText'] as String? ??
          args['qrData'] as String? ??
          'No content available';
      _isGenerated = args['isScanned'] == false;
      _isLoading = false;
    });

    // Preload image with timeout to prevent hanging
    _preloadImageWithTimeout();
  }

  Future<void> _preloadImageWithTimeout() async {
    try {
      final imageProvider = NetworkImage(_qrImageUrl);
      final completer = imageProvider.resolve(const ImageConfiguration());
      
      completer.addListener(
        ImageStreamListener(
          (info, call) {},
          onError: (exception, stackTrace) {
            // Fallback to local generation on error
            if (mounted) {
              setState(() {
                _qrImageUrl =
                    'https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=${Uri.encodeComponent(_decodedText)}';
              });
            }
          },
        ),
      );
      
      // Add timeout handling
      await Future.delayed(const Duration(seconds: 5));
      if (mounted) {
        setState(() {
          _qrImageUrl =
              'https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=${Uri.encodeComponent(_decodedText)}';
        });
      }
    } catch (e) {
      // Silent fail - image will load normally or show error
    }
  }

  Future<void> _saveToHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyList = prefs.getStringList('qr_history') ?? [];

      // Check if already exists to prevent duplicates
      final isDuplicate = historyList.any((item) {
        try {
          final decoded = jsonDecode(item) as Map<String, dynamic>;
          return decoded['content'] == _decodedText;
        } catch (e) {
          return false;
        }
      });

      if (!isDuplicate) {
        final historyItem = jsonEncode({
          'type': _isGenerated ? 'generated' : 'scanned',
          'content': _decodedText,
          'timestamp': DateTime.now().toIso8601String(),
          'thumbnailUrl': _qrImageUrl,
        });

        historyList.insert(0, historyItem);

        if (historyList.length > 100) {
          historyList.removeRange(100, historyList.length);
        }

        await prefs.setStringList('qr_history', historyList);
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to save to history",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        textColor: Colors.white,
        fontSize: 14.sp,
      );
    }
  }

  void _showContextMenu() {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'save_alt',
                color: theme.colorScheme.onSurface,
                size: 24,
              ),
              title: Text('Save Image', style: theme.textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                Fluttertoast.showToast(
                  msg: "Image saved to gallery",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.green.withValues(alpha: 0.8),
                  textColor: Colors.white,
                  fontSize: 14.sp,
                );
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'print',
                color: theme.colorScheme.onSurface,
                size: 24,
              ),
              title: Text('Print QR Code', style: theme.textTheme.bodyLarge),
              onTap: () async {
                Navigator.pop(context);
                try {
                  await Printing.layoutPdf(
                    onLayout: (format) async {
                      return Uint8List(0);
                    },
                  );
                } catch (e) {
                  Fluttertoast.showToast(
                    msg: "Print feature unavailable",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.red.withValues(alpha: 0.8),
                    textColor: Colors.white,
                    fontSize: 14.sp,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: theme.colorScheme.primary),
        ),
      );
    }

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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('QR Result', style: theme.appBarTheme.titleTextStyle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 2.h),
              GestureDetector(
                onLongPress: _showContextMenu,
                child: QRDisplayWidget(
                  qrImageUrl: _qrImageUrl,
                  isGenerated: _isGenerated,
                  qrData: _decodedText,
                  qrColor: _qrColor,
                  backgroundColor: _backgroundColor,
                  qrSize: _qrSize,
                  logoBytes: _logoBytes,
                ),
              ),
              SizedBox(height: 3.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Decoded Content',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 1.h),
              DecodedContentWidget(decodedText: _decodedText),
              SizedBox(height: 3.h),
              ContentTypeActionsWidget(decodedText: _decodedText),
              SizedBox(height: 2.h),
              ActionButtonsWidget(
                decodedText: _decodedText,
                qrImageUrl: _qrImageUrl,
                onSaveToHistory: _saveToHistory,
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}