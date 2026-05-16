import 'package:green_miles_app/core/auth_input_validator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  SupabaseAuthService(this._client);

  final SupabaseClient _client;

  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<void> signIn({required String email, required String password}) async {
    await _client.auth.signInWithPassword(
      email: AuthInputValidator.normalizeEmail(email),
      password: password,
    );
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = AuthInputValidator.normalizeEmail(email);
    final response = await _client.auth.signUp(
      email: normalizedEmail,
      password: password,
      data: {'full_name': name},
    );

    final userId = response.user?.id;
    if (userId == null) {
      return;
    }


    final currentUserId = _client.auth.currentUser?.id;
    if (_client.auth.currentSession == null || currentUserId != userId) {
      return;
    }

    await _client.from('profiles').upsert({
      'id': userId,
      'email': normalizedEmail,
      'full_name': name,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  /// Initiates an email change for the currently signed-in user.
  /// Supabase will send a confirmation link to both the current and new email.
  /// The email is only updated in auth.users after both links are clicked.
  Future<void> updateEmail(String newEmail) async {
    await _client.auth.updateUser(
      UserAttributes(email: newEmail),
    );
  }
}
