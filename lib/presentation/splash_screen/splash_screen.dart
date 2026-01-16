import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';

/// Splash Screen provides branded app launch experience while initializing core services
/// and preparing the QR scanner functionality.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeApp();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  Future<void> _initializeApp() async {
    // Simulate initialization tasks
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() {
        _isInitializing = false;
      });

      // Navigate to home screen
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushReplacementNamed('/home-screen');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                _buildLogo(theme),
                SizedBox(height: 3.h),
                _buildAppName(theme),
                SizedBox(height: 2.h),
                _buildTagline(theme),
                const Spacer(flex: 2),
                _buildLoadingIndicator(theme),
                SizedBox(height: 3.h),
                _buildPrivacyMessage(theme),
                SizedBox(height: 4.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(ThemeData theme) {
    return Container(
      width: 30.w,
      height: 30.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: CustomIconWidget(
          iconName: 'qr_code_scanner',
          color: theme.colorScheme.primary,
          size: 15.w,
        ),
      ),
    );
  }

  Widget _buildAppName(ThemeData theme) {
    return Text(
      'QuickQR',
      style: theme.textTheme.headlineLarge?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 24.sp,
      ),
    );
  }

  Widget _buildTagline(ThemeData theme) {
    return Text(
      'Scan & Generate QR Codes Instantly',
      style: theme.textTheme.bodyMedium?.copyWith(
        color: Colors.white.withValues(alpha: 0.9),
        fontSize: 11.sp,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildLoadingIndicator(ThemeData theme) {
    return _isInitializing
        ? SizedBox(
            width: 8.w,
            height: 8.w,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : CustomIconWidget(
            iconName: 'check_circle',
            color: Colors.white,
            size: 8.w,
          );
  }

  Widget _buildPrivacyMessage(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'lock',
            color: Colors.white.withValues(alpha: 0.8),
            size: 4.w,
          ),
          SizedBox(width: 2.w),
          Flexible(
            child: Text(
              'Your data stays on your device',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 10.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
