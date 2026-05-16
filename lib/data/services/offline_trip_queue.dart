import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists unsynchronised trip payloads to [SharedPreferences] so they
/// survive process restarts and are uploaded once connectivity returns.
class OfflineTripQueue {
  OfflineTripQueue._(this._prefs);

  static const _key = 'offline_trip_queue';

  final SharedPreferences _prefs;

  // ---------------------------------------------------------------------------
  // Factory
  // ---------------------------------------------------------------------------

  static Future<OfflineTripQueue> create() async {
    final prefs = await SharedPreferences.getInstance();
    return OfflineTripQueue._(prefs);
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Whether there are trips waiting to be uploaded.
  bool get hasPending => _readList().isNotEmpty;

  /// Append [tripPayload] to the persistent queue.
  Future<void> enqueue(Map<String, dynamic> tripPayload) async {
    final list = _readList();
    list.add(tripPayload);
    await _writeList(list);
  }

  /// Return all queued trips and atomically clear the queue.
  ///
  /// Call [enqueue] again for any entries that failed to upload so they are
  /// not permanently lost.
  Future<List<Map<String, dynamic>>> dequeueAll() async {
    final list = _readList();
    if (list.isEmpty) return const [];
    await _prefs.remove(_key);
    return list;
  }

  // ---------------------------------------------------------------------------
  // Persistence helpers
  // ---------------------------------------------------------------------------

  List<Map<String, dynamic>> _readList() {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    } catch (_) {
      // Corrupt data — start fresh.
    }
    return [];
  }

  Future<void> _writeList(List<Map<String, dynamic>> list) async {
    await _prefs.setString(_key, jsonEncode(list));
  }
}
