import 'package:flutter/material.dart';
import 'package:green_miles_app/core/app_strings.dart';
import 'package:green_miles_app/core/app_theme.dart';
import 'package:green_miles_app/view/onboarding/sign_in_screen.dart';
import 'package:green_miles_app/view/onboarding/sign_up_screen.dart';
import 'package:green_miles_app/view/widgets/buttons.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_index < 2) {
      _controller.nextPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SignUpScreen()));
  }

  void _skip() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SignInScreen()));
  }

  List<_OnboardingData> get _pages => const [
    _OnboardingData(
      icon: Icons.directions_bike_rounded,
      title: AppStrings.onboardingTitleOne,
      description: AppStrings.onboardingDescOne,
    ),
    _OnboardingData(
      icon: Icons.insights_rounded,
      title: AppStrings.onboardingTitleTwo,
      description: AppStrings.onboardingDescTwo,
    ),
    _OnboardingData(
      icon: Icons.workspace_premium_rounded,
      title: AppStrings.onboardingTitleThree,
      description: AppStrings.onboardingDescThree,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _skip,
                  child: Text(AppStrings.skip, style: textTheme.titleMedium?.copyWith(color: AppTheme.primaryColor)),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (value) => setState(() => _index = value),
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(AppTheme.radiusL),
                          ),
                          child: Icon(page.icon, size: 64, color: Colors.white),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: textTheme.headlineMedium?.copyWith(color: AppTheme.textColor, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            page.description,
                            textAlign: TextAlign.center,
                            style: textTheme.bodyLarge?.copyWith(color: AppTheme.subtitleTextColor),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (dot) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _index == dot ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _index == dot ? AppTheme.primaryColor : AppTheme.primaryColor.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              EcoPrimaryButton(label: _index == 2 ? AppStrings.getStarted : AppStrings.next, onPressed: _next),
              const SizedBox(height: 12),
              EcoOutlinedButton(
                label: AppStrings.signIn,
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SignInScreen()));
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
  });
}

