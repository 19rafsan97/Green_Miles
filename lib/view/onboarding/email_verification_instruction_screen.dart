import 'package:flutter/material.dart';
import 'package:green_miles_app/core/app_strings.dart';
import 'package:green_miles_app/core/app_theme.dart';
import 'package:green_miles_app/view/onboarding/sign_in_screen.dart';

class EmailVerificationInstructionScreen extends StatelessWidget {
  const EmailVerificationInstructionScreen({
    super.key,
    required this.email,
  });

  final String email;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  gradient: AppTheme.primaryGradient,
                ),
                child: const Icon(
                  Icons.mark_email_read_rounded,
                  color: Colors.white,
                  size: 42,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppStrings.checkEmailTitle,
                style: textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'We sent a verification link to $email. Please verify your email before signing in.',
                style: textTheme.bodyMedium,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const SignInScreen(),
                    ),
                    (route) => false,
                  );
                },
                child: const Text(AppStrings.goToSignIn),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

