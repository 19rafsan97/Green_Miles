import 'package:green_miles_app/data/models/trip_model.dart';

class CarbonStatModel {
  final TransportMode mode;
  final double co2Saved; // in kilograms
  final DateTime date; // Represents the day for this stat

  CarbonStatModel({
    required this.mode,
    required this.co2Saved,
    required this.date,
  });
}

