import 'package:flutter/material.dart';
import 'package:green_miles_app/core/app_strings.dart';
import 'package:green_miles_app/core/app_theme.dart';
import 'package:green_miles_app/data/models/user_model.dart';

class StatsCard extends StatelessWidget {
  final UserModel user;

  const StatsCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.primaryColor.withValues(alpha: 0.06),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem(context, user.totalCo2Saved.toStringAsFixed(1), AppStrings.totalCo2Saved),
            _buildStatItem(context, user.totalDistance.toStringAsFixed(1), AppStrings.totalDistance),
            _buildStatItem(context, user.totalTrips.toString(), AppStrings.totalTrips),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(
          value,
          style: textTheme.headlineSmall?.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(color: AppTheme.subtitleTextColor),
        ),
      ],
    );
  }
}

