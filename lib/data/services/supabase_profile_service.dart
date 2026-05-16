import 'dart:typed_data';
import 'package:green_miles_app/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProfileService {
  SupabaseProfileService(this._client);

  final SupabaseClient _client;

  Future<UserModel?> fetchCurrentUserProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return null;
    }

    final rows = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .limit(1);

    if (rows.isEmpty) {
      return UserModel(
        uid: user.id,
        name:
            (user.userMetadata?['full_name'] ??
                    user.email ??
                    'Green Miles User')
                .toString(),
        email: user.email ?? '',
      );
    }

    return UserModel.fromSupabase(
      Map<String, dynamic>.from(rows.first),
      fallbackEmail: user.email,
    );
  }

  Future<UserModel?> updateCurrentUserProfile({
    required String name,
    required String avatarUrl,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return null;
    }

    final rows = await _client
        .from('profiles')
        .upsert({
          'id': user.id,
          'email': user.email,
          'full_name': name.trim(),
          'avatar_url': avatarUrl.trim(),
          'updated_at': DateTime.now().toIso8601String(),
        }, onConflict: 'id')
        .select()
        .limit(1);

    if (rows.isEmpty) {
      return fetchCurrentUserProfile();
    }

    return UserModel.fromSupabase(
      Map<String, dynamic>.from(rows.first),
      fallbackEmail: user.email,
    );
  }

  Future<String> uploadAvatarBytes(Uint8List bytes, String fileName, {String? contentType}) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const AuthException('User must be logged in to upload an avatar');
    }

    final path = '${user.id}/$fileName';
    await _client.storage.from('avatars').uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(upsert: true, contentType: contentType),
    );

    // We add a timestamp query parameter to bypass potential caching since it's upserted
    final publicUrl = _client.storage.from('avatars').getPublicUrl(path);
    return '$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Writes the confirmed email from [auth.currentUser] into the profiles table.
  /// Call this after receiving a USER_UPDATED auth event so the local profiles
  /// row stays in sync with auth.users.
  Future<void> syncEmailToProfile() async {
    final user = _client.auth.currentUser;
    if (user == null || user.email == null) return;

    await _client.from('profiles').upsert(
      {
        'id': user.id,
        'email': user.email,
        'updated_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'id',
    );
  }
}
