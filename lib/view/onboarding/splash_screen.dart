import 'package:flutter/material.dart';
import 'package:green_miles_app/core/app_strings.dart';
import 'package:green_miles_app/core/app_theme.dart';
import 'package:green_miles_app/view/main_screen.dart';
import 'package:green_miles_app/view/onboarding/welcome_screen.dart';
import 'package:green_miles_app/view/widgets/brand_logo.dart';
import 'package:green_miles_app/viewmodel/splash_viewmodel.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _handleNavigation();
  }

  Future<void> _handleNavigation() async {
    final viewModel = context.read<SplashViewModel>();
    while (viewModel.isChecking) {
      await Future.delayed(const Duration(milliseconds: 200));
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => viewModel.isAuthenticated ? const MainScreen() : const WelcomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const BrandLogo(height: 96),
              const SizedBox(height: 16),
              Text(AppStrings.splashTagline, style: textTheme.bodyLarge?.copyWith(color: Colors.white.withValues(alpha: 0.86))),
              const SizedBox(height: 24),
              const CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

