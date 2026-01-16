import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'dart:convert';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/generate_button_widget.dart';
import './widgets/qr_customization_widget.dart';
import './widgets/qr_preview_widget.dart';
import './widgets/text_input_widget.dart';

/// Generate Screen - Create QR codes from text input with live preview
/// Supports text and URL input with instant QR code generation
class GenerateScreen extends StatefulWidget {
  const GenerateScreen({super.key});

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  String _qrData = '';
  String? _errorText;
  bool _isDarkMode = false;
  Color _qrColor = Colors.black;
  Color _backgroundColor = Colors.white;
  double _qrSize = 300;
  dynamic _logoImage;
  Uint8List? _logoBytes;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  void _onTextChanged(String value) {
    setState(() {
      _qrData = value.trim();
      _errorText = null;
    });
  }

  Future<void> _pickQrColor() async {
    final Color? pickedColor = await showDialog<Color>(
      context: context,
      builder: (context) =>
          _ColorPickerDialog(initialColor: _qrColor, title: 'Select QR Color'),
    );

    if (pickedColor != null) {
      setState(() {
        _qrColor = pickedColor;
      });
    }
  }

  Future<void> _pickBackgroundColor() async {
    final Color? pickedColor = await showDialog<Color>(
      context: context,
      builder: (context) => _ColorPickerDialog(
        initialColor: _backgroundColor,
        title: 'Select Background Color',
      ),
    );

    if (pickedColor != null) {
      setState(() {
        _backgroundColor = pickedColor;
      });
    }
  }

  Future<void> _pickLogo() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (image != null) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          setState(() {
            _logoImage = bytes;
            _logoBytes = bytes;
          });
        } else {
          final bytes = await image.readAsBytes();
          setState(() {
            _logoImage = File(image.path);
            _logoBytes = bytes;
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorText = 'Failed to load image';
      });
    }
  }

  void _removeLogo() {
    setState(() {
      _logoImage = null;
      _logoBytes = null;
    });
  }

  Future<void> _generateQrCode() async {
    if (_qrData.isEmpty) {
      setState(() {
        _errorText = 'Please enter text or URL';
      });
      return;
    }

    // Validate QR data size limit (max ~4296 characters for QR codes)
    if (_qrData.length > 4296) {
      setState(() {
        _errorText = 'Content too large. Maximum 4296 characters allowed.';
      });
      return;
    }

    HapticFeedback.mediumImpact();

    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList('qr_history') ?? [];

    final historyItem = {
      'type': 'generated',
      'content': _qrData,
      'timestamp': DateTime.now().toIso8601String(),
      'thumbnailUrl':
          'https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=${Uri.encodeComponent(_qrData)}',
    };

    history.insert(0, jsonEncode(historyItem));

    // Enforce history limit consistently
    if (history.length > 100) {
      history.removeRange(100, history.length);
    }

    await prefs.setStringList('qr_history', history);

    if (mounted) {
      Navigator.of(context).pushNamed(
        '/result-screen',
        arguments: {
          'qrData': _qrData,
          'type': 'generated',
          'qrColor': _qrColor,
          'backgroundColor': _backgroundColor,
          'qrSize': _qrSize,
          'logoBytes': _logoBytes,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isInputValid = _qrData.isNotEmpty;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color:
                theme.appBarTheme.foregroundColor ??
                theme.colorScheme.onSurface,
            size: 6.w,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Generate', style: theme.appBarTheme.titleTextStyle),
        actions: [
          if (isInputValid)
            TextButton(
              onPressed: _generateQrCode,
              child: Text(
                'Generate',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            )
          else
            TextButton(
              onPressed: null,
              child: Text(
                'Generate',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.4,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter Content',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                TextInputWidget(
                  controller: _textController,
                  onChanged: _onTextChanged,
                  errorText: _errorText,
                ),
                SizedBox(height: 3.h),
                QrCustomizationWidget(
                  qrColor: _qrColor,
                  backgroundColor: _backgroundColor,
                  qrSize: _qrSize,
                  logoImage: _logoImage,
                  onColorPickerTap: _pickQrColor,
                  onBackgroundColorPickerTap: _pickBackgroundColor,
                  onSizeChanged: (value) {
                    setState(() {
                      _qrSize = value;
                    });
                  },
                  onLogoPickerTap: _pickLogo,
                  onLogoRemove: _removeLogo,
                ),
                SizedBox(height: 3.h),
                Text(
                  'Preview',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Center(
                  child: QrPreviewWidget(
                    qrData: _qrData,
                    isDarkMode: _isDarkMode,
                    qrColor: _qrColor,
                    backgroundColor: _backgroundColor,
                    size: 80.w,
                    embeddedImage: _logoImage,
                  ),
                ),
                SizedBox(height: 4.h),
                GenerateButtonWidget(
                  isEnabled: isInputValid,
                  onPressed: _generateQrCode,
                ),
                SizedBox(height: 2.h),
                Center(
                  child: Text(
                    'QR code updates as you type',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.6,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorPickerDialog extends StatefulWidget {
  final Color initialColor;
  final String title;

  const _ColorPickerDialog({required this.initialColor, required this.title});

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late Color _selectedColor;

  final List<Color> _predefinedColors = [
    Colors.black,
    Colors.white,
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
  ];

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 80.w,
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 2.w,
            mainAxisSpacing: 2.w,
          ),
          itemCount: _predefinedColors.length,
          itemBuilder: (context, index) {
            final color = _predefinedColors[index];
            final isSelected = _selectedColor == color;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = color;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        color: color == Colors.white || color == Colors.yellow
                            ? Colors.black
                            : Colors.white,
                        size: 6.w,
                      )
                    : null,
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_selectedColor),
          child: const Text('Select'),
        ),
      ],
    );
  }
}
