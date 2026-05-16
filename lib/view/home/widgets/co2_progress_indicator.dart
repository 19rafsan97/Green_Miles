import 'package:flutter/material.dart';
import 'package:green_miles_app/core/app_strings.dart';
import 'package:green_miles_app/core/app_theme.dart';

class Co2ProgressIndicator extends StatelessWidget {
  final double co2Saved;
  final double goal;

  const Co2ProgressIndicator({
    super.key,
    required this.co2Saved,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final progress = (co2Saved / goal).clamp(0.0, 1.0);

    return SizedBox(
      width: 190,
      height: 190,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 14,
            strokeCap: StrokeCap.round,
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.08),
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'This week',
                  style: textTheme.bodySmall?.copyWith(color: AppTheme.subtitleTextColor),
                ),
                Text(
                  co2Saved.toStringAsFixed(1),
                  style: textTheme.headlineLarge?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  AppStrings.kg,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppTheme.subtitleTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

