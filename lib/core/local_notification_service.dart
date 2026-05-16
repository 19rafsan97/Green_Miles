import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:green_miles_app/data/models/trip_model.dart';

class LocalNotificationService {
  LocalNotificationService._();

  static final LocalNotificationService instance = LocalNotificationService._();

  // ── Alert channel — high importance, plays sound, heads-up display ─────────
  static const String _alertChannelId = 'tracking_alerts';
  static const String _alertChannelName = 'Tracking Alerts';
  static const String _alertChannelDescription =
      'Warnings and trip status updates while tracking.';

  // ── Progress channel — low importance, silent, ongoing / no dismiss ────────
  static const String _progressChannelId = 'trip_progress';
  static const String _progressChannelName = 'Trip Progress';
  static const String _progressChannelDescription =
      'Live trip stats shown while a trip is in progress.';

  /// Fixed notification ID for the ongoing trip HUD. Using a fixed ID means
  /// every `show()` call updates the same notification in place.
  static const int _progressNotificationId = 1;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // ── Initialisation ──────────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosSettings = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initializationSettings);

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    // Alert channel — heads-up, sound
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _alertChannelId,
        _alertChannelName,
        description: _alertChannelDescription,
        importance: Importance.high,
      ),
    );

    // Progress channel — silent ongoing HUD
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _progressChannelId,
        _progressChannelName,
        description: _progressChannelDescription,
        importance: Importance.low,
        playSound: false,
        enableVibration: false,
        showBadge: false,
      ),
    );

    _isInitialized = true;
  }

  Future<void> requestPermissions() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    final iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);

    final macOsPlugin = _plugin
        .resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>();
    await macOsPlugin?.requestPermissions(alert: true, badge: true, sound: true);
  }

  // ── Alert notifications (warnings / cancellations) ─────────────────────────

  /// Shows a one-time heads-up alert (warning, cancellation, etc.).
  /// Each call generates a unique ID so alerts stack rather than replace.
  Future<void> showTrackingNotification({
    required String title,
    required String body,
    bool isCritical = false,
  }) async {
    if (!_isInitialized) await initialize();

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _alertChannelId,
        _alertChannelName,
        channelDescription: _alertChannelDescription,
        importance: isCritical ? Importance.max : Importance.high,
        priority: isCritical ? Priority.max : Priority.high,
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel:
            isCritical ? InterruptionLevel.critical : InterruptionLevel.active,
      ),
    );

    // Use a timestamp-based ID so alerts don't overwrite each other.
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await _plugin.show(id, title, body, details, payload: 'tracking_alert');
  }

  // ── Ongoing trip progress notification ─────────────────────────────────────

  /// Creates or updates the persistent trip HUD notification.
  ///
  /// Call this once when the trip starts, then once per second from the timer.
  Future<void> showTripProgressNotification({
    required TransportMode mode,
    required int durationSeconds,
    required double distanceKm,
    required double co2Kg,
  }) async {
    if (!_isInitialized) await initialize();

    final modeEmoji = _modeEmoji(mode);
    final modeLabel = _modeLabel(mode);
    final title = '$modeEmoji $modeLabel - Trip in progress';
    final body =
        '⏱ ${_formatDuration(durationSeconds)}   '
        '📍 ${distanceKm.toStringAsFixed(2)} km   '
        '🌿 ${co2Kg.toStringAsFixed(2)} kg CO₂ saved';

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _progressChannelId,
        _progressChannelName,
        channelDescription: _progressChannelDescription,
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        autoCancel: false,
        playSound: false,
        enableVibration: false,
        onlyAlertOnce: true,
        showWhen: false,
        // Keep the notification visible on the lock screen.
        visibility: NotificationVisibility.public,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: false,
        presentBadge: false,
        presentSound: false,
      ),
    );

    await _plugin.show(
      _progressNotificationId,
      title,
      body,
      details,
      payload: 'trip_progress',
    );
  }

  /// Removes the ongoing trip HUD notification.
  Future<void> dismissTripProgressNotification() async {
    if (!_isInitialized) return;
    await _plugin.cancel(_progressNotificationId);
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  String _formatDuration(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    if (h > 0) {
      return '${h}h ${m.toString().padLeft(2, '0')}m';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _modeEmoji(TransportMode mode) {
    return switch (mode) {
      TransportMode.walk => '🚶',
      TransportMode.bicycle => '🚴',
      TransportMode.eScooter => '🛴',
      TransportMode.eBike => '⚡🚲',
      TransportMode.bus => '🚌',
      TransportMode.publicTransport => '🚇',
      TransportMode.electricVehicle => '⚡🚗',
      TransportMode.car => '🚗',
    };
  }

  String _modeLabel(TransportMode mode) {
    return switch (mode) {
      TransportMode.walk => 'Walking',
      TransportMode.bicycle => 'Cycling',
      TransportMode.eScooter => 'E-scooter',
      TransportMode.eBike => 'E-bike',
      TransportMode.bus => 'Bus',
      TransportMode.publicTransport => 'Public Transport',
      TransportMode.electricVehicle => 'Electric Vehicle',
      TransportMode.car => 'Car',
    };
  }
}
