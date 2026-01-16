import 'package:flutter/material.dart';

/// Custom bottom navigation bar widget for the QR Scanner application.
/// Implements bottom-heavy action placement for optimal thumb reach.
///
/// This widget is parameterized and reusable - it does NOT contain
/// hardcoded navigation logic. The parent widget controls navigation
/// through the currentIndex and onTap callback.
class CustomBottomBar extends StatelessWidget {
  /// Current selected index
  final int currentIndex;

  /// Callback when a navigation item is tapped
  final Function(int) onTap;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: colorScheme.onSurfaceVariant,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: [
            // Home - Central hub for primary functions
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined, size: 24),
              activeIcon: const Icon(Icons.home, size: 24),
              label: 'Home',
              tooltip: 'Home Hub',
            ),

            // Scan - Quick access to camera scanning
            BottomNavigationBarItem(
              icon: const Icon(Icons.qr_code_scanner_outlined, size: 24),
              activeIcon: const Icon(Icons.qr_code_scanner, size: 24),
              label: 'Scan',
              tooltip: 'Scan QR Code',
            ),

            // Generate - Create new QR codes
            BottomNavigationBarItem(
              icon: const Icon(Icons.qr_code_2_outlined, size: 24),
              activeIcon: const Icon(Icons.qr_code_2, size: 24),
              label: 'Generate',
              tooltip: 'Generate QR Code',
            ),

            // History - Access previous scans and generations
            BottomNavigationBarItem(
              icon: const Icon(Icons.history_outlined, size: 24),
              activeIcon: const Icon(Icons.history, size: 24),
              label: 'History',
              tooltip: 'Scan History',
            ),

            // Settings - App configuration and preferences
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_outlined, size: 24),
              activeIcon: const Icon(Icons.settings, size: 24),
              label: 'Settings',
              tooltip: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
