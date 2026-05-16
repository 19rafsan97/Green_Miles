import 'package:flutter/material.dart';
import 'package:green_miles_app/core/app_theme.dart';
import 'package:green_miles_app/data/models/trip_model.dart';
import 'package:intl/intl.dart';

class TripHistoryList extends StatelessWidget {
  final List<TripModel> trips;

  const TripHistoryList({super.key, required this.trips});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final trip = trips[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(trip.transportIcon, color: AppTheme.primaryColor, size: 24),
            ),
            title: Text(
              '${trip.distance.toStringAsFixed(1)} km via ${trip.transportMode.toString().split('.').last}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              DateFormat.yMMMd().add_jm().format(trip.startTime),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            trailing: SizedBox(
              width: 88,
              child: Text(
                '${trip.co2Saved.toStringAsFixed(1)} kg',
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }
}

