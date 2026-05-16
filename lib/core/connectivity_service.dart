import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Thin wrapper around [Connectivity] that exposes a simple boolean stream
/// (`true` = online, `false` = offline) and a one-shot [isOnline] check.
///
/// Usage:
/// ```dart
/// final svc = ConnectivityService();
/// svc.onlineStream.listen((online) {
///   if (online) syncPendingTrips();
/// });
/// ```
class ConnectivityService {
  ConnectivityService() {
    _subscription = Connectivity()
        .onConnectivityChanged
        .listen(_onConnectivityChanged);
  }

  final _controller = StreamController<bool>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Emits `true` when connectivity is gained, `false` when lost.
  Stream<bool> get onlineStream => _controller.stream;

  /// One-shot connectivity check (does not emit on the stream).
  Future<bool> isOnline() async {
    final results = await Connectivity().checkConnectivity();
    return _isConnected(results);
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    _controller.add(_isConnected(results));
  }

  static bool _isConnected(List<ConnectivityResult> results) {
    return results.any(
      (r) =>
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.ethernet,
    );
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
