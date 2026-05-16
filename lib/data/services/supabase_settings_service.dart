import 'package:green_miles_app/data/models/user_settings_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseSettingsService {
  SupabaseSettingsService(this._client);

  final SupabaseClient _client;

  Future<UserSettingsModel> fetchCurrentUserSettings() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return UserSettingsModel.defaults();
    }

    final profileVisible = await _fetchProfileVisibility(user.id);

    try {
      final rows = await _client
          .from('user_settings')
          .select()
          .eq('user_id', user.id)
          .limit(1);

      if (rows.isEmpty) {
        return UserSettingsModel.defaults()
            .copyWith(profileVisible: profileVisible);
      }

      return UserSettingsModel.fromSupabase(Map<String, dynamic>.from(rows.first))
          .copyWith(profileVisible: profileVisible);
    } catch (error) {
      if (_isFeatureUnavailable(error)) {
        return UserSettingsModel.defaults()
            .copyWith(profileVisible: profileVisible);
      }
      rethrow;
    }
  }

  Future<UserSettingsModel> saveCurrentUserSettings(
    UserSettingsModel settings,
  ) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return settings;
    }

    List<dynamic> rows = const [];
    try {
      rows = await _client
          .from('user_settings')
          .upsert(
            {
              'user_id': user.id,
              ...settings.toSupabaseMap(),
            },
            onConflict: 'user_id',
          )
          .select()
          .limit(1);
    } catch (error) {
      if (!_isFeatureUnavailable(error)) {
        rethrow;
      }
    }

    try {
      await _client.from('profiles').update({
        'profile_visible': settings.profileVisible,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', user.id);
    } catch (error) {
      if (!_isFeatureUnavailable(error)) {
        rethrow;
      }
    }

    if (rows.isEmpty) {
      return settings;
    }

    return UserSettingsModel.fromSupabase(Map<String, dynamic>.from(rows.first))
        .copyWith(profileVisible: settings.profileVisible);
  }

  Future<bool> _fetchProfileVisibility(String userId) async {
    try {
      final profileRows = await _client
          .from('profiles')
          .select('profile_visible')
          .eq('id', userId)
          .limit(1);

      return profileRows.isEmpty
          ? true
          : profileRows.first['profile_visible'] != false;
    } catch (error) {
      if (_isFeatureUnavailable(error)) {
        return true;
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
    return (message.contains('user_settings') ||
            message.contains('profile_visible') ||
            message.contains('profiles')) &&
        (message.contains('does not exist') ||
            message.contains('permission denied') ||
            message.contains('not found'));
  }
}


