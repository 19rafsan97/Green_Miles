import 'package:green_miles_app/data/models/app_notification_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseNotificationService {
  SupabaseNotificationService(this._client);

  final SupabaseClient _client;

  Future<List<AppNotificationModel>> fetchNotifications({int limit = 50}) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const [];
    }

    try {
      final rows = await _client
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(limit);

      return rows
          .map(
            (row) => AppNotificationModel.fromSupabase(
              Map<String, dynamic>.from(row),
            ),
          )
          .toList();
    } catch (error) {
      if (_isFeatureUnavailable(error)) {
        return const [];
      }
      rethrow;
    }
  }

  Future<void> markNotificationRead(int notificationId) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return;
    }

    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId)
          .eq('user_id', user.id);
    } catch (error) {
      if (_isFeatureUnavailable(error)) {
        return;
      }
      rethrow;
    }
  }

  Future<void> markAllNotificationsRead() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return;
    }

    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', user.id)
          .eq('is_read', false);
    } catch (error) {
      if (_isFeatureUnavailable(error)) {
        return;
      }
      rethrow;
    }
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
    return message.contains('notifications') &&
        (message.contains('does not exist') ||
            message.contains('permission denied') ||
            message.contains('not found'));
  }
}

