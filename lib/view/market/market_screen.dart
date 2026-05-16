import 'package:flutter/material.dart';
import 'package:green_miles_app/core/app_strings.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.marketplace),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            AppStrings.marketplaceComingSoon,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

