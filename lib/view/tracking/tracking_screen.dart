import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:green_miles_app/core/app_theme.dart';
import 'package:green_miles_app/core/local_notification_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:green_miles_app/viewmodel/tracking_viewmodel.dart';
import 'package:provider/provider.dart';

import 'widgets/transport_mode_selector.dart';
import 'widgets/trip_control_panel.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final MapController _mapController = MapController();
  int _lastNotificationVersion = 0;
  bool _hasCenteredInitially = false;
  static const double _minMapZoom = 2;
  static const double _maxMapZoom = 19;

  void _zoomBy(double delta) {
    try {
      final camera = _mapController.camera;
      final targetZoom = (camera.zoom + delta)
          .clamp(_minMapZoom, _maxMapZoom)
          .toDouble();
      _mapController.move(camera.center, targetZoom);
    } catch (_) {
      return;
    }
  }

  void _recenterOnCurrentLocation(LatLng? markerPoint) {
    if (markerPoint == null) {
      return;
    }

    try {
      final zoom = _mapController.camera.zoom
          .clamp(_minMapZoom, _maxMapZoom)
          .toDouble();
      _mapController.move(markerPoint, zoom);
    } catch (_) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track New Trip'),
        actions: [
          Consumer<TrackingViewModel>(
            builder: (context, viewModel, child) {
              return PopupMenuButton<AntiCheatPolicy>(
                tooltip: 'Anti-cheat policy',
                initialValue: viewModel.antiCheatPolicy,
                onSelected: viewModel.setAntiCheatPolicy,
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: AntiCheatPolicy.strict,
                    child: Text('Strict'),
                  ),
                  PopupMenuItem(
                    value: AntiCheatPolicy.normal,
                    child: Text('Normal'),
                  ),
                  PopupMenuItem(
                    value: AntiCheatPolicy.lenient,
                    child: Text('Lenient'),
                  ),
                ],
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Center(
                    child: Text(
                      _policyLabel(viewModel.antiCheatPolicy),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<TrackingViewModel>(
        builder: (context, viewModel, child) {
          final currentLocation = viewModel.currentLocation;
          final currentLat = currentLocation?.latitude;
          final currentLon = currentLocation?.longitude;
          final hasCurrentLocation = currentLat != null && currentLon != null;
          final markerPoint = hasCurrentLocation
              ? LatLng(currentLat, currentLon)
              : null;

          if (hasCurrentLocation && markerPoint != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) {
                return;
              }

              final zoom = viewModel.trackingState == TrackingState.idle
                  ? 17.0
                  : _mapController.camera.zoom;
              if (!_hasCenteredInitially ||
                  viewModel.trackingState == TrackingState.tracking) {
                try {
                  _mapController.move(markerPoint, zoom);
                } catch (_) {
                  return;
                }
                _hasCenteredInitially = true;
              }
            });
          }

          if (viewModel.notificationVersion > _lastNotificationVersion &&
              viewModel.latestNotification != null) {
            _lastNotificationVersion = viewModel.notificationVersion;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) {
                return;
              }

              final notification = viewModel.latestNotification;
              if (notification == null) {
                return;
              }

              unawaited(
                LocalNotificationService.instance.showTrackingNotification(
                  title: notification.isCancellation
                      ? 'Trip canceled'
                      : 'Tracking warning',
                  body: notification.message,
                  isCritical: notification.isCancellation,
                ),
              );

              if (notification.isCancellation) {
                showDialog<void>(
                  context: context,
                  builder: (dialogContext) {
                    return AlertDialog(
                      title: const Text('Trip Canceled'),
                      content: Text(notification.message),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
                return;
              }

              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(SnackBar(content: Text(notification.message)));
            });
          }

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: viewModel.mapCenter,
                  initialZoom: hasCurrentLocation ? 17 : 2,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.green_miles_app',
                  ),
                  if (viewModel.routePoints.length > 1)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: viewModel.routePoints,
                          color: AppTheme.primaryColor,
                          strokeWidth: 5,
                        ),
                      ],
                    ),
                  if (markerPoint != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: markerPoint,
                          width: 42,
                          height: 42,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.my_location,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  const RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution('OpenStreetMap contributors'),
                    ],
                  ),
                ],
              ),

              Align(
                alignment: Alignment.topRight,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12, right: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _MapControlButton(
                          tooltip: 'Zoom in',
                          icon: Icons.add,
                          onPressed: () => _zoomBy(1),
                        ),
                        const SizedBox(height: 8),
                        _MapControlButton(
                          tooltip: 'Zoom out',
                          icon: Icons.remove,
                          onPressed: () => _zoomBy(-1),
                        ),
                        const SizedBox(height: 8),
                        _MapControlButton(
                          tooltip: 'Current location',
                          icon: Icons.my_location,
                          onPressed: markerPoint == null
                              ? null
                              : () => _recenterOnCurrentLocation(markerPoint),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (viewModel.trackingState == TrackingState.idle)
                      TransportModeSelector(
                        selectedMode: viewModel.selectedTransportMode,
                        onModeSelected: viewModel.setTransportMode,
                      ),

                    TripControlPanel(
                      trackingState: viewModel.trackingState,
                      durationInSeconds: viewModel.tripDurationInSeconds,
                      distanceInKm: viewModel.distanceInKm,
                      co2SavedInKg: viewModel.co2SavedInKg,
                      canStartTrip: viewModel.canStartTrip,
                      onStartPressed: viewModel.startTrip,
                      onStopPressed: viewModel.stopTrip,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

String _policyLabel(AntiCheatPolicy policy) {
  return switch (policy) {
    AntiCheatPolicy.strict => 'Strict',
    AntiCheatPolicy.normal => 'Normal',
    AntiCheatPolicy.lenient => 'Lenient',
  };
}

class _MapControlButton extends StatelessWidget {
  const _MapControlButton({
    required this.tooltip,
    required this.icon,
    this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      shape: const CircleBorder(),
      color: Colors.white,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, color: AppTheme.primaryColor),
      ),
    );
  }
}
