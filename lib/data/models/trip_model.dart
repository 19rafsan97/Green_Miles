import 'package:flutter/material.dart';

enum TransportMode {
  walk,
  bicycle,
  eScooter,
  eBike,
  bus,
  publicTransport,
  electricVehicle,
  car,
}

class TripModel {
  final String id;
  final String userId;
  final TransportMode transportMode;
  final DateTime startTime;
  final DateTime endTime;
  final double distance; // in kilometers
  final double co2Saved; // in kilograms
  // Could also include a polyline of the route
  // final List<LatLng> route;

  TripModel({
    required this.id,
    required this.userId,
    required this.transportMode,
    required this.startTime,
    required this.endTime,
    required this.distance,
    required this.co2Saved,
  });

  Duration get duration => endTime.difference(startTime);

  // Helper to get icon for transport mode
  IconData get transportIcon {
    switch (transportMode) {
      case TransportMode.walk:
        return Icons.directions_walk;
      case TransportMode.bicycle:
        return Icons.directions_bike;
      case TransportMode.eScooter:
        return Icons.electric_scooter;
      case TransportMode.eBike:
        return Icons.pedal_bike;
      case TransportMode.bus:
        return Icons.directions_bus;
      case TransportMode.publicTransport:
        return Icons.directions_bus;
      case TransportMode.electricVehicle:
        return Icons.electric_car;
      case TransportMode.car:
        return Icons.directions_car;
    }
  }

  String get transportLabel {
    switch (transportMode) {
      case TransportMode.walk:
        return 'Walking';
      case TransportMode.bicycle:
        return 'Cycling';
      case TransportMode.eScooter:
        return 'E-scooter';
      case TransportMode.eBike:
        return 'E-bike';
      case TransportMode.bus:
        return 'Bus';
      case TransportMode.publicTransport:
        return 'Public Transport';
      case TransportMode.electricVehicle:
        return 'Electric Vehicle';
      case TransportMode.car:
        return 'Car';
    }
  }

  factory TripModel.fromSupabase(Map<String, dynamic> data) {
    final start = DateTime.tryParse((data['start_time'] ?? '').toString()) ?? DateTime.now();
    final end = DateTime.tryParse((data['end_time'] ?? '').toString()) ?? start;
    return TripModel(
      id: (data['id'] ?? '').toString(),
      userId: (data['user_id'] ?? '').toString(),
      transportMode: modeFromString((data['transport_mode'] ?? '').toString()),
      startTime: start,
      endTime: end,
      distance: _toDouble(data['distance_km'] ?? data['distance']),
      co2Saved: _toDouble(data['co2_saved_kg'] ?? data['co2Saved']),
    );
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      'id': id,
      'user_id': userId,
      'transport_mode': transportMode.name,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'distance_km': distance,
      'co2_saved_kg': co2Saved,
    };
  }

  static TransportMode modeFromString(String value) {
    return TransportMode.values.firstWhere(
      (mode) => mode.name.toLowerCase() == value.toLowerCase(),
      orElse: () => TransportMode.walk,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }
}

