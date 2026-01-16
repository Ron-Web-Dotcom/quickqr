import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'dart:async';

import '../core/app_export.dart';
import '../widgets/custom_error_widget.dart';
import './routes/app_routes.dart';
import './theme/app_theme.dart';
import './widgets/custom_error_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool hasShownError = false;

  // 🚨 CRITICAL: Custom error handling - DO NOT REMOVE
  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (!hasShownError) {
      hasShownError = true;

      // Reset flag after 3 seconds to allow error widget on new screens
      Future.delayed(Duration(seconds: 5), () {
        hasShownError = false;
      });

      return CustomErrorWidget(errorDetails: details);
    }
    return SizedBox.shrink();
  };

  // 🚨 CRITICAL: Device orientation lock - DO NOT REMOVE
  Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
  ]).then((value) {
    runApp(MyApp());
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;
  Timer? _themePollingTimer;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
    _listenToThemeChanges();
  }

  @override
  void dispose() {
    _themePollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    if (mounted) {
      setState(() {
        _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
      });
    }
  }

  void _listenToThemeChanges() async {
    final prefs = await SharedPreferences.getInstance();

    // Use proper Timer instead of Future.doWhile to prevent memory leak
    _themePollingTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final isDarkMode = prefs.getBool('isDarkMode') ?? false;
      final newThemeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;

      if (_themeMode != newThemeMode) {
        setState(() {
          _themeMode = newThemeMode;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          title: 'quickqr',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _themeMode,
          // 🚨 CRITICAL: NEVER REMOVE OR MODIFY
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(1.0)),
              child: child!,
            );
          },
          // 🚨 END CRITICAL SECTION
          debugShowCheckedModeBanner: false,
          routes: AppRoutes.routes,
          initialRoute: AppRoutes.initial,
        );
      },
    );
  }
}