import 'package:flutter/material.dart';
import 'package:green_miles_app/core/app_strings.dart';
import 'package:green_miles_app/core/app_theme.dart';
import 'package:green_miles_app/viewmodel/tracking_viewmodel.dart';

class TripControlPanel extends StatelessWidget {
  final TrackingState trackingState;
  final int durationInSeconds;
  final double distanceInKm;
  final double co2SavedInKg;
  final bool canStartTrip;
  final VoidCallback onStartPressed;
  final VoidCallback onStopPressed;

  const TripControlPanel({
    super.key,
    required this.trackingState,
    required this.durationInSeconds,
    required this.distanceInKm,
    required this.co2SavedInKg,
    required this.canStartTrip,
    required this.onStartPressed,
    required this.onStopPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trackingState != TrackingState.idle) _buildStatsRow(context),
            if (trackingState == TrackingState.idle) _buildIdleHint(context),
            const SizedBox(height: 20),
            _buildControlButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildIdleHint(BuildContext context) {
    return Text(
      'Select a transport mode (including Walking) and tap Start Trip.',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.subtitleTextColor),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final duration = Duration(seconds: durationInSeconds);
    final String twoDigitMinutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final String twoDigitSeconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(context, '${distanceInKm.toStringAsFixed(2)} km', AppStrings.distance),
        _buildStatItem(context, '$twoDigitMinutes:$twoDigitSeconds', AppStrings.duration),
        _buildStatItem(context, '${co2SavedInKg.toStringAsFixed(2)} kg', AppStrings.co2Saved),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(
          value,
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(color: AppTheme.subtitleTextColor),
        ),
      ],
    );
  }

  Widget _buildControlButton(BuildContext context) {
    final isIdle = trackingState == TrackingState.idle;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(isIdle ? Icons.play_arrow : Icons.stop),
        label: Text(
          (isIdle ? AppStrings.startTrip : AppStrings.endTrip).toUpperCase(),
        ),
        onPressed: isIdle
            ? (canStartTrip ? onStartPressed : null)
            : onStopPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isIdle ? AppTheme.primaryColor : Colors.redAccent,
          padding: const EdgeInsets.symmetric(vertical: 20),
          textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 16),
        ),
      ),
    );
  }
}

