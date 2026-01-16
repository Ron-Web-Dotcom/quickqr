import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/settings_screen/settings_screen.dart';
import '../presentation/generate_screen/generate_screen.dart';
import '../presentation/history_screen/history_screen.dart';
import '../presentation/home_screen/home_screen.dart';
import '../presentation/result_screen/result_screen.dart';
import '../presentation/scan_screen/scan_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splash = '/splash-screen';
  static const String settings = '/settings-screen';
  static const String generate = '/generate-screen';
  static const String history = '/history-screen';
  static const String home = '/home-screen';
  static const String result = '/result-screen';
  static const String scan = '/scan-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splash: (context) => const SplashScreen(),
    settings: (context) => const SettingsScreen(),
    generate: (context) => const GenerateScreen(),
    history: (context) => const HistoryScreen(),
    home: (context) => const HomeScreen(),
    result: (context) => const ResultScreen(),
    scan: (context) => const ScanScreen(),
    // TODO: Add your other routes here
  };
}
