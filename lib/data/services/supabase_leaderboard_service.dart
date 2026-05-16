import 'package:green_miles_app/data/models/user_model.dart';
import 'package:green_miles_app/viewmodel/leaderboard_viewmodel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseLeaderboardService {
  SupabaseLeaderboardService(this._client);

  final SupabaseClient _client;

  Future<List<UserModel>> fetchLeaderboard(LeaderboardPeriod period) async {
    try {
      final rows = await _client.rpc(
        'get_leaderboard',
        params: {
          'p_period': _periodKey(period),
          'p_limit': 50,
        },
      );

      return _mapRowsToUsers(List<dynamic>.from(rows));
    } catch (error) {
      if (_isFeatureUnavailable(error)) {
        return _fetchLeaderboardFallback(period);
      }
      rethrow;
    }
  }

  Future<List<UserModel>> _fetchLeaderboardFallback(
    LeaderboardPeriod period,
  ) async {
    try {
      if (period == LeaderboardPeriod.allTime) {
        final rows = await _fetchProfiles(
          includeProfileVisible: true,
          includeTotalCo2Saved: true,
        );
        final users = _mapRowsToUsers(rows)
          ..sort((a, b) => b.totalCo2Saved.compareTo(a.totalCo2Saved));
        return users.take(50).toList();
      }

      final now = DateTime.now();
      final since = period == LeaderboardPeriod.weekly
          ? now.subtract(const Duration(days: 7))
          : now.subtract(const Duration(days: 30));

      final tripRows = await _client
          .from('trips')
          .select('user_id, co2_saved_kg')
          .gte('start_time', since.toIso8601String());

      final scores = <String, double>{};
      for (final row in tripRows) {
        final map = Map<String, dynamic>.from(row);
        final userId = (map['user_id'] ?? '').toString();
        if (userId.isEmpty) {
          continue;
        }
        scores[userId] = (scores[userId] ?? 0) + _toDouble(map['co2_saved_kg']);
      }

      final profileRows = await _fetchProfiles(
        includeProfileVisible: true,
        includeTotalCo2Saved: false,
      );

      final rowsWithScores = profileRows.map((row) {
        final profile = Map<String, dynamic>.from(row);
        final userId = (profile['id'] ?? '').toString();
        profile['total_co2_saved'] = scores[userId] ?? 0.0;
        return profile;
      }).toList()
        ..sort((a, b) =>
            _toDouble(b['total_co2_saved']).compareTo(_toDouble(a['total_co2_saved'])));

      final users = _mapRowsToUsers(rowsWithScores);
      return users.take(50).toList();
    } catch (error) {
      if (_isFeatureUnavailable(error)) {
        return const [];
      }
      rethrow;
    }
  }

  Future<List<dynamic>> _fetchProfiles({
    required bool includeProfileVisible,
    required bool includeTotalCo2Saved,
    List<String>? userIds,
  }) async {
    final fields = <String>[
      'id',
      'full_name',
      'avatar_url',
      'points',
      'total_distance',
      'total_trips',
      if (includeTotalCo2Saved) 'total_co2_saved',
      if (includeProfileVisible) 'profile_visible',
    ];

    try {
      final query = _client.from('profiles').select(fields.join(', '));
      if (userIds != null && userIds.isNotEmpty) {
        return await query.inFilter('id', userIds);
      }
      if (includeTotalCo2Saved && userIds == null) {
        return await query.order('total_co2_saved', ascending: false).limit(50);
      }
      return await query;
    } catch (error) {
      if (!includeProfileVisible || !_isFeatureUnavailable(error)) {
        rethrow;
      }

      // Older schema may not have profiles.profile_visible yet.
      return _fetchProfiles(
        includeProfileVisible: false,
        includeTotalCo2Saved: includeTotalCo2Saved,
        userIds: userIds,
      );
    }
  }

  List<UserModel> _mapRowsToUsers(List<dynamic> rows) {
    return rows.map((row) {
      final map = Map<String, dynamic>.from(row);
      final model = UserModel.fromSupabase(map);
      return _maskUserIfPrivate(model, map);
    }).toList();
  }

  String _periodKey(LeaderboardPeriod period) {
    switch (period) {
      case LeaderboardPeriod.weekly:
        return 'weekly';
      case LeaderboardPeriod.monthly:
        return 'monthly';
      case LeaderboardPeriod.allTime:
        return 'all_time';
    }
  }

  UserModel _maskUserIfPrivate(UserModel user, Map<String, dynamic> row) {
    if (row['profile_visible'] == false) {
      return UserModel(
        uid: user.uid,
        name: 'Private User',
        email: '',
        profileImageUrl: '',
        points: user.points,
        totalCo2Saved: user.totalCo2Saved,
        totalDistance: user.totalDistance,
        totalTrips: user.totalTrips,
      );
    }
    return user;
  }

  bool _isFeatureUnavailable(Object error) {
    if (error is! PostgrestException) {
      return false;
    }

    const codes = <String>{
      '42P01', // undefined_table
      '42703', // undefined_column
      '42501', // insufficient_privilege
      'PGRST202', // undefined_function (API representation)
      'PGRST205', // table not found
    };

    if (error.code != null && codes.contains(error.code)) {
      return true;
    }

    final message = error.message.toLowerCase();
    return message.contains('get_leaderboard') ||
        message.contains('profile_visible') ||
        message.contains('profiles') ||
        message.contains('trips') ||
        message.contains('not found') ||
        message.contains('does not exist') ||
        message.contains('permission denied');
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
