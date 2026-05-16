import 'package:flutter/material.dart';
import 'package:green_miles_app/core/app_theme.dart';
import 'package:green_miles_app/data/models/trip_model.dart';

class TransportModeSelector extends StatelessWidget {
  static const List<TransportMode> _allowedTrackingModes = [
    TransportMode.walk,
    TransportMode.bicycle,
    TransportMode.eScooter,
    TransportMode.eBike,
    TransportMode.bus,
  ];

  final TransportMode? selectedMode;
  final ValueChanged<TransportMode> onModeSelected;

  const TransportModeSelector({
    super.key,
    required this.selectedMode,
    required this.onModeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.shadowColor.withValues(alpha: 0.2)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _allowedTrackingModes.map((mode) {
            return _buildModeChip(context, mode);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildModeChip(BuildContext context, TransportMode mode) {
    final isSelected = selectedMode == mode;
    final trip = TripModel(id: '', userId: '', transportMode: mode, startTime: DateTime.now(), endTime: DateTime.now(), distance: 0, co2Saved: 0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(trip.transportLabel),
        avatar: Icon(
          trip.transportIcon,
          color: isSelected ? Colors.white : AppTheme.primaryColor,
        ),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            onModeSelected(mode);
          }
        },
        selectedColor: AppTheme.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppTheme.textColor,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppTheme.primaryColor : AppTheme.shadowColor.withValues(alpha: 0.4),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}

