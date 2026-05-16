import 'dart:io';
import 'package:green_miles_app/data/models/carbon_stat_model.dart';
import 'package:green_miles_app/data/models/trip_model.dart';
import 'package:green_miles_app/data/services/offline_trip_queue.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseTripService {
  SupabaseTripService(this._client, this._offlineQueue);

  final SupabaseClient _client;
  final OfflineTripQueue _offlineQueue;

  Future<List<TripModel>> fetchTripHistory({int limit = 20}) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const [];
    }

    final rows = await _client
        .from('trips')
        .select()
        .eq('user_id', user.id)
        .order('start_time', ascending: false)
        .limit(limit);

    return rows
        .map((row) => TripModel.fromSupabase(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<void> saveTrip({
    required TransportMode mode,
    required DateTime startTime,
    required DateTime endTime,
    required double distanceKm,
    required double co2SavedKg,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return;
    }

    final payload = {
      'user_id': user.id,
      'transport_mode': mode.name,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'distance_km': distanceKm,
      'co2_saved_kg': co2SavedKg,
    };

    try {
      await _client.from('trips').insert(payload);
    } on SocketException catch (_) {
      // No network — store locally and upload later.
      await _offlineQueue.enqueue(payload);
    } on PostgrestException catch (e) {
      // Supabase may also wrap connectivity issues as PostgREST errors.
      if (_isNetworkError(e)) {
        await _offlineQueue.enqueue(payload);
      } else {
        rethrow;
      }
    }
  }

  /// Upload every trip that was queued while the device was offline.
  ///
  /// Trips that fail to upload (e.g. still no internet) are re-enqueued so
  /// nothing is permanently lost.
  Future<void> syncPendingTrips() async {
    if (!_offlineQueue.hasPending) return;

    final pending = await _offlineQueue.dequeueAll();
    for (final payload in pending) {
      try {
        await _client.from('trips').insert(payload);
      } on SocketException catch (_) {
        await _offlineQueue.enqueue(payload);
      } on PostgrestException catch (e) {
        if (_isNetworkError(e)) {
          await _offlineQueue.enqueue(payload);
        }
        // Non-network errors (e.g. constraint violations) are intentionally
        // dropped so they don't block the rest of the queue.
      } catch (_) {
        // Unknown errors — re-enqueue to avoid data loss.
        await _offlineQueue.enqueue(payload);
      }
    }
  }

  static bool _isNetworkError(PostgrestException e) {
    // Supabase-dart wraps network failures with code 0 or messages that
    // contain 'network' / 'connection' / 'timeout'.
    final msg = e.message.toLowerCase();
    return e.code == '0' ||
        msg.contains('network') ||
        msg.contains('connection') ||
        msg.contains('timeout') ||
        msg.contains('socket');
  }

  Future<double> fetchWeeklyCo2Saved() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return 0;
    }

    final weekStart = DateTime.now().subtract(const Duration(days: 7));
    final rows = await _client
        .from('trips')
        .select('co2_saved_kg')
        .eq('user_id', user.id)
        .gte('start_time', weekStart.toIso8601String());

    return rows.fold<double>(0, (sum, row) {
      final value = row['co2_saved_kg'];
      return sum + _toDouble(value);
    });
  }

  Future<List<CarbonStatModel>> fetchLast7DaysStats() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const [];
    }

    final start = DateTime.now().subtract(const Duration(days: 6));
    final rows = await _client
        .from('trips')
        .select('start_time, transport_mode, co2_saved_kg')
        .eq('user_id', user.id)
        .gte(
          'start_time',
          DateTime(start.year, start.month, start.day).toIso8601String(),
        )
        .order('start_time', ascending: true);

    final Map<String, _DailyAggregate> byDay = {};
    for (final row in rows) {
      final map = Map<String, dynamic>.from(row);
      final date = DateTime.tryParse((map['start_time'] ?? '').toString());
      if (date == null) {
        continue;
      }
      final dayKey = DateTime(
        date.year,
        date.month,
        date.day,
      ).toIso8601String();
      final aggregate = byDay.putIfAbsent(dayKey, _DailyAggregate.new);
      final mode = TripModel.modeFromString(
        (map['transport_mode'] ?? '').toString(),
      );
      final co2 = _toDouble(map['co2_saved_kg']);
      aggregate.total += co2;
      aggregate.lastMode = mode;
    }

    final List<CarbonStatModel> stats = [];
    for (var i = 0; i < 7; i++) {
      final date = DateTime.now().subtract(Duration(days: 6 - i));
      final day = DateTime(date.year, date.month, date.day);
      final key = day.toIso8601String();
      final aggregate = byDay[key];
      stats.add(
        CarbonStatModel(
          mode: aggregate?.lastMode ?? TransportMode.walk,
          co2Saved: aggregate?.total ?? 0,
          date: day,
        ),
      );
    }

    return stats;
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }
}

class _DailyAggregate {
  _DailyAggregate();

  double total = 0;
  TransportMode lastMode = TransportMode.walk;
}
