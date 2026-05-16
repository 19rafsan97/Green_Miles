import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:green_miles_app/core/local_notification_service.dart';
import 'package:green_miles_app/data/models/trip_model.dart';
import 'package:green_miles_app/data/services/supabase_app_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

enum TrackingState { idle, tracking, paused }

enum AntiCheatPolicy { strict, normal, lenient }

enum TrackingNotificationType {
  warning,
  tripCanceledMismatch,
  tripCanceledStationary,
}

class TrackingNotification {
  final String message;
  final TrackingNotificationType type;

  const TrackingNotification({
    required this.message,
    required this.type,
  });

  bool get isCancellation =>
      type == TrackingNotificationType.tripCanceledMismatch ||
      type == TrackingNotificationType.tripCanceledStationary;
}

class TrackingViewModel extends ChangeNotifier {
  TrackingViewModel(this._service) {
    _requestPermissionAndGetCurrentLocation();
  }

  final SupabaseAppService _service;
  final Location _location = Location();
  StreamSubscription<LocationData>? _locationSubscription;

  TrackingState _trackingState = TrackingState.idle;
  TransportMode? _selectedTransportMode;
  LocationData? _currentLocation;
  LocationData? _displayLocation;
  final List<LatLng> _routePoints = [];
  Timer? _timer;
  int _tripDurationInSeconds = 0;
  double _distanceInMeters = 0;
  bool _isStartingTrip = false;
  DateTime? _tripStartedAt;
  bool _tripCanceledByPolicy = false;
  bool _canceledByStationary = false;

  AntiCheatPolicy _antiCheatPolicy = AntiCheatPolicy.normal;
  int _cheatWarningCount = 0;
  DateTime? _overspeedStartedAt;
  DateTime? _lastWarningAt;
  TrackingNotification? _latestNotification;
  int _notificationVersion = 0;
  DateTime? _lastMovementAt;
  bool _stationaryWarningIssued = false;

  static const LatLng _fallbackMapCenter = LatLng(0, 0);
  static const double _minAccurateSpeedMps = 0.8;
  static const double _stationaryMarkerDeadbandMeters = 10;
  static const double _movingMarkerDeadbandMeters = 4;

  TrackingState get trackingState => _trackingState;
  TransportMode? get selectedTransportMode => _selectedTransportMode;
  bool get canStartTrip =>
      _trackingState == TrackingState.idle && _selectedTransportMode != null;
  LocationData? get currentLocation => _displayLocation ?? _currentLocation;
  List<LatLng> get routePoints => List.unmodifiable(_routePoints);
  int get tripDurationInSeconds => _tripDurationInSeconds;
  double get distanceInKm => _distanceInMeters / 1000;
  double get co2SavedInKg => _calculateCo2Saved(distanceInKm);
  AntiCheatPolicy get antiCheatPolicy => _antiCheatPolicy;
  int get cheatWarningCount => _cheatWarningCount;
  TrackingNotification? get latestNotification => _latestNotification;
  int get notificationVersion => _notificationVersion;
  LatLng get mapCenter {
    final location = currentLocation;
    final lat = location?.latitude;
    final lon = location?.longitude;
    if (lat == null || lon == null) {
      return _fallbackMapCenter;
    }
    return LatLng(lat, lon);
  }

  void setTransportMode(TransportMode mode) {
    _selectedTransportMode = mode;
    notifyListeners();
  }

  void setAntiCheatPolicy(AntiCheatPolicy policy) {
    if (_antiCheatPolicy == policy) {
      return;
    }
    _antiCheatPolicy = policy;
    // Reset mode-dependent timing so a mode switch does not carry stale penalties.
    _overspeedStartedAt = null;
    _lastWarningAt = null;
    _stationaryWarningIssued = false;
    if (_trackingState == TrackingState.tracking) {
      _lastMovementAt = DateTime.now();
    }
    notifyListeners();
  }

  void startTrip() {
    if (canStartTrip) {
      unawaited(_beginTrip());
    }
  }

  Future<void> _beginTrip() async {
    if (_isStartingTrip) {
      return;
    }
    if (_selectedTransportMode == null) {
      return;
    }
    _isStartingTrip = true;
    try {
      final isLocationAvailable = await _requestPermissionAndGetCurrentLocation();
      if (!isLocationAvailable) {
        return;
      }

      _trackingState = TrackingState.tracking;
      _routePoints.clear();
      _tripDurationInSeconds = 0;
      _distanceInMeters = 0;
      _tripStartedAt = DateTime.now();
      _tripCanceledByPolicy = false;
      _canceledByStationary = false;
      _lastMovementAt = _tripStartedAt;
      _stationaryWarningIssued = false;
      _resetCheatDetection();
      _displayLocation = _currentLocation;

      final startLat = _currentLocation?.latitude;
      final startLon = _currentLocation?.longitude;
      if (startLat != null && startLon != null) {
        _routePoints.add(LatLng(startLat, startLon));
      }

      _startLocationUpdates();
      _startTimer();

      // Show the persistent trip HUD notification immediately.
      unawaited(
        LocalNotificationService.instance.showTripProgressNotification(
          mode: _selectedTransportMode!,
          durationSeconds: _tripDurationInSeconds,
          distanceKm: distanceInKm,
          co2Kg: co2SavedInKg,
        ),
      );

      notifyListeners();
    } finally {
      _isStartingTrip = false;
    }
  }

  void stopTrip({bool clearNotification = true}) {
    if (_trackingState == TrackingState.tracking || _trackingState == TrackingState.paused) {
      final startedAt = _tripStartedAt;
      final traveledKm = distanceInKm;
      final savedKg = co2SavedInKg;
      final mode = _selectedTransportMode;
      // For stationary cancellations we still save the trip up to the last
      // recorded movement. For anti-cheat mismatch cancellations we discard.
      final shouldSave = !_tripCanceledByPolicy || _canceledByStationary;
      // Use the timestamp of the last recorded movement as the end time when
      // the trip was auto-canceled due to inactivity.
      final endedAt = (_canceledByStationary && _lastMovementAt != null)
          ? _lastMovementAt!
          : DateTime.now();

      _trackingState = TrackingState.idle;
      _locationSubscription?.cancel();
      _locationSubscription = null;
      _timer?.cancel();
      _timer = null;
      _tripStartedAt = null;
      _lastMovementAt = null;
      _stationaryWarningIssued = false;
      _canceledByStationary = false;
      _resetCheatDetection(clearNotification: clearNotification);

      // Remove the ongoing trip HUD from the notification shade.
      unawaited(LocalNotificationService.instance.dismissTripProgressNotification());

      notifyListeners();

      if (mode != null && shouldSave && startedAt != null && traveledKm > 0) {
        unawaited(
          _service.saveTrip(
            mode: mode,
            startTime: startedAt,
            endTime: endedAt,
            distanceKm: traveledKm,
            co2SavedKg: savedKg,
          ),
        );
      }
    }
  }

  Future<bool> _requestPermissionAndGetCurrentLocation() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return false;
      }
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
    }

    if (permissionGranted != PermissionStatus.granted) {
      return false;
    }

    _currentLocation = await _location.getLocation();
    _displayLocation = _currentLocation;
    notifyListeners();
    return true;
  }

  void _startLocationUpdates() {
    _locationSubscription?.cancel();
    unawaited(
      _location.changeSettings(
        accuracy: LocationAccuracy.high,
        interval: 5000,
        distanceFilter: 5,
      ),
    );
    _locationSubscription = _location.onLocationChanged.listen((LocationData newLocation) {
      final lat = newLocation.latitude;
      final lon = newLocation.longitude;
      if (lat == null || lon == null) {
        return;
      }

      if (_trackingState == TrackingState.tracking) {
        final now = DateTime.now();
        final newPoint = LatLng(lat, lon);
        if (_routePoints.isNotEmpty) {
          final segmentMeters = _calculateDistanceInMeters(_routePoints.last, newPoint);
          if (_shouldCountMovement(newLocation, segmentMeters)) {
            _distanceInMeters += segmentMeters;
            _routePoints.add(newPoint);
            _lastMovementAt = now;
            _stationaryWarningIssued = false;
          } else {
            _evaluateStationary(now);
          }
        } else {
          _routePoints.add(newPoint);
          _lastMovementAt = now;
        }

        final speedMps = newLocation.speed ?? 0;
        _evaluateCheating(speedMps);
      }

      _currentLocation = newLocation;
      _updateDisplayedLocation(newLocation);
      notifyListeners();
    });
  }

  bool _updateDisplayedLocation(LocationData newLocation) {
    final lat = newLocation.latitude;
    final lon = newLocation.longitude;
    if (lat == null || lon == null) {
      return false;
    }

    final accuracyMeters = newLocation.accuracy;
    if (accuracyMeters != null && accuracyMeters > _maxMarkerAccuracyMeters) {
      return false;
    }

    final previous = _displayLocation;
    if (previous == null || previous.latitude == null || previous.longitude == null) {
      _displayLocation = newLocation;
      return true;
    }

    final deltaMeters = _calculateDistanceInMeters(
      LatLng(previous.latitude!, previous.longitude!),
      LatLng(lat, lon),
    );
    final speedMps = newLocation.speed ?? 0;
    final baseThreshold = speedMps >= _minAccurateSpeedMps
        ? _movingMarkerDeadbandMeters
        : _stationaryMarkerDeadbandMeters;
    final accuracyThreshold = accuracyMeters != null
        ? accuracyMeters.clamp(0, _stationaryMarkerDeadbandMeters).toDouble()
        : 0;
    final movementThreshold = math.max(baseThreshold, accuracyThreshold);

    if (deltaMeters < movementThreshold) {
      return false;
    }

    _displayLocation = newLocation;
    return true;
  }

  double _calculateDistanceInMeters(LatLng from, LatLng to) {
    const earthRadiusMeters = 6371000.0;
    final dLat = _degToRad(to.latitude - from.latitude);
    final dLon = _degToRad(to.longitude - from.longitude);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(from.latitude)) *
            math.cos(_degToRad(to.latitude)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusMeters * c;
  }

  double _degToRad(double deg) => deg * (math.pi / 180);

  double _calculateCo2Saved(double distanceKm) {
    const carEmissionKgPerKm = 0.192;
    final selectedMode = _selectedTransportMode;
    if (selectedMode == null) {
      return 0;
    }
    final modeEmissionKgPerKm = switch (selectedMode) {
      TransportMode.walk => 0,
      TransportMode.bicycle => 0,
      TransportMode.eScooter => 0.02,
      TransportMode.eBike => 0.01,
      TransportMode.bus => 0.105,
      TransportMode.publicTransport => 0.105,
      TransportMode.electricVehicle => 0.053,
      TransportMode.car => carEmissionKgPerKm,
    };
    return math.max(0, (carEmissionKgPerKm - modeEmissionKgPerKm) * distanceKm);
  }

  void _evaluateCheating(double speedMps) {
    final selectedMode = _selectedTransportMode;
    if (selectedMode == null) {
      return;
    }

    final now = DateTime.now();
    final thresholdMps = _maxAllowedSpeedMps(selectedMode);
    final overspeedGracePeriod = _overspeedGracePeriod;
    final warningInterval = _warningInterval;
    final maxCheatWarnings = _maxCheatWarnings;

    if (speedMps <= thresholdMps) {
      _overspeedStartedAt = null;
      return;
    }

    _overspeedStartedAt ??= now;
    if (now.difference(_overspeedStartedAt!) < overspeedGracePeriod) {
      return;
    }

    final warningCooldownPassed = _lastWarningAt == null || now.difference(_lastWarningAt!) >= warningInterval;
    if (!warningCooldownPassed) {
      return;
    }

    _cheatWarningCount++;
    _lastWarningAt = now;

    if (_cheatWarningCount >= maxCheatWarnings) {
      _tripCanceledByPolicy = true;
      _publishNotification(
        'Trip canceled due to mismatch between selected transport mode and detected speed.',
        TrackingNotificationType.tripCanceledMismatch,
      );
      stopTrip(clearNotification: false);
      return;
    }

    final warningsLeft = maxCheatWarnings - _cheatWarningCount;
    _publishNotification(
      'Speed too high for ${_modeLabel(selectedMode)}. Warning $_cheatWarningCount/$maxCheatWarnings. $warningsLeft warning(s) left.',
      TrackingNotificationType.warning,
    );
  }

  bool _shouldCountMovement(LocationData newLocation, double segmentMeters) {
    final speedMps = newLocation.speed ?? 0;
    if (speedMps >= _minAccurateSpeedMps) {
      return true;
    }

    final accuracyMeters = newLocation.accuracy;
    if (accuracyMeters != null && accuracyMeters > _maxAcceptedAccuracyMeters) {
      return false;
    }

    final accuracyThreshold = accuracyMeters != null ? accuracyMeters * 0.6 : 0;
    final movementThreshold = math.max(_minMovementDistanceMeters, accuracyThreshold);
    return segmentMeters >= movementThreshold;
  }

  void _evaluateStationary(DateTime now) {
    final lastMovementAt = _lastMovementAt;
    if (lastMovementAt == null) {
      _lastMovementAt = now;
      return;
    }

    final stationaryDuration = now.difference(lastMovementAt);
    if (!_stationaryWarningIssued && stationaryDuration >= _stationaryWarningAfter) {
      _stationaryWarningIssued = true;
      _publishNotification(
        'No movement detected. Keep moving or the trip will be canceled.',
        TrackingNotificationType.warning,
      );
    }

    if (stationaryDuration >= _stationaryCancelAfter) {
      _tripCanceledByPolicy = true;
      _canceledByStationary = true;
      _publishNotification(
        'Trip saved and canceled because no movement was detected for ${_stationaryCancelAfter.inSeconds} seconds.',
        TrackingNotificationType.tripCanceledStationary,
      );
      stopTrip(clearNotification: false);
    }
  }

  String _modeLabel(TransportMode mode) {
    switch (mode) {
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
        return 'Public transport';
      case TransportMode.electricVehicle:
        return 'Electric vehicle';
      case TransportMode.car:
        return 'Car';
    }
  }

  double _maxAllowedSpeedMps(TransportMode mode) {
    final speedByPolicy = switch (_antiCheatPolicy) {
      AntiCheatPolicy.strict => _strictSpeedCapsKmh,
      AntiCheatPolicy.normal => _normalSpeedCapsKmh,
      AntiCheatPolicy.lenient => _lenientSpeedCapsKmh,
    };

    final maxSpeedKmH = speedByPolicy[mode] ?? _normalSpeedCapsKmh[mode] ?? 30.0;
    return maxSpeedKmH / 3.6;
  }

  Duration get _warningInterval {
    return switch (_antiCheatPolicy) {
      AntiCheatPolicy.strict => const Duration(minutes: 2),
      AntiCheatPolicy.normal => const Duration(minutes: 3),
      AntiCheatPolicy.lenient => const Duration(minutes: 4),
    };
  }

  Duration get _overspeedGracePeriod {
    return switch (_antiCheatPolicy) {
      AntiCheatPolicy.strict => const Duration(seconds: 10),
      AntiCheatPolicy.normal => const Duration(seconds: 20),
      AntiCheatPolicy.lenient => const Duration(seconds: 35),
    };
  }

  int get _maxCheatWarnings {
    return switch (_antiCheatPolicy) {
      AntiCheatPolicy.strict => 2,
      AntiCheatPolicy.normal => 3,
      AntiCheatPolicy.lenient => 4,
    };
  }

  double get _minMovementDistanceMeters {
    return switch (_antiCheatPolicy) {
      AntiCheatPolicy.strict => 16,
      AntiCheatPolicy.normal => 12,
      AntiCheatPolicy.lenient => 8,
    };
  }

  double get _maxAcceptedAccuracyMeters {
    return switch (_antiCheatPolicy) {
      AntiCheatPolicy.strict => 25,
      AntiCheatPolicy.normal => 35,
      AntiCheatPolicy.lenient => 50,
    };
  }

  double get _maxMarkerAccuracyMeters {
    return switch (_antiCheatPolicy) {
      AntiCheatPolicy.strict => 35,
      AntiCheatPolicy.normal => 50,
      AntiCheatPolicy.lenient => 70,
    };
  }

  Duration get _stationaryWarningAfter {
    return switch (_antiCheatPolicy) {
      AntiCheatPolicy.strict => const Duration(seconds: 30),
      AntiCheatPolicy.normal => const Duration(seconds: 45),
      AntiCheatPolicy.lenient => const Duration(seconds: 75),
    };
  }

  Duration get _stationaryCancelAfter {
    return switch (_antiCheatPolicy) {
      AntiCheatPolicy.strict => const Duration(seconds: 45),
      AntiCheatPolicy.normal => const Duration(minutes: 1),
      AntiCheatPolicy.lenient => const Duration(minutes: 2),
    };
  }

  static const Map<TransportMode, double> _strictSpeedCapsKmh = {
    TransportMode.walk: 6,
    TransportMode.bicycle: 28,
    TransportMode.eScooter: 24,
    TransportMode.eBike: 32,
    TransportMode.bus: 80,
    TransportMode.publicTransport: 80,
    TransportMode.electricVehicle: 45,
    TransportMode.car: 100,
  };

  static const Map<TransportMode, double> _normalSpeedCapsKmh = {
    TransportMode.walk: 9,
    TransportMode.bicycle: 35,
    TransportMode.eScooter: 32,
    TransportMode.eBike: 40,
    TransportMode.bus: 95,
    TransportMode.publicTransport: 95,
    TransportMode.electricVehicle: 60,
    TransportMode.car: 130,
  };

  static const Map<TransportMode, double> _lenientSpeedCapsKmh = {
    TransportMode.walk: 12,
    TransportMode.bicycle: 42,
    TransportMode.eScooter: 40,
    TransportMode.eBike: 48,
    TransportMode.bus: 110,
    TransportMode.publicTransport: 110,
    TransportMode.electricVehicle: 75,
    TransportMode.car: 150,
  };

  void _publishNotification(String message, TrackingNotificationType type) {
    _latestNotification = TrackingNotification(message: message, type: type);
    _notificationVersion++;
  }

  void _resetCheatDetection({bool clearNotification = true}) {
    _cheatWarningCount = 0;
    _overspeedStartedAt = null;
    _lastWarningAt = null;
    _tripCanceledByPolicy = false;
    _canceledByStationary = false;
    if (clearNotification) {
      _latestNotification = null;
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _tripDurationInSeconds++;
      // Update the persistent notification with the latest trip stats.
      unawaited(
        LocalNotificationService.instance.showTripProgressNotification(
          mode: _selectedTransportMode ?? TransportMode.walk,
          durationSeconds: _tripDurationInSeconds,
          distanceKm: distanceInKm,
          co2Kg: co2SavedInKg,
        ),
      );
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _timer?.cancel();
    // Safety net: if the viewmodel is disposed mid-trip, clear the notification.
    unawaited(LocalNotificationService.instance.dismissTripProgressNotification());
    super.dispose();
  }
}

