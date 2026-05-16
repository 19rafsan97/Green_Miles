import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:green_miles_app/data/services/supabase_app_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._service) {
    _isAuthenticated = _service.currentSession != null;
    _authSubscription = _service.authStateChanges.listen((state) {
      _isAuthenticated = state.session != null;
      notifyListeners();
    });
  }

  final SupabaseAppService _service;
  StreamSubscription<AuthState>? _authSubscription;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;
  String? _lastRawAuthErrorCode;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  String? get lastRawAuthErrorCode => _lastRawAuthErrorCode;

  Future<void> signIn({required String email, required String password}) async {
    if (_isLoading) {
      return;
    }
    _setLoading(true);
    try {
      await _service.signIn(email: email, password: password);
      _error = null;
      _lastRawAuthErrorCode = null;
    } on AuthException catch (error) {
      _lastRawAuthErrorCode = _extractAuthErrorCode(error);
      _error = _mapAuthError(error.message, isSignup: false);
      _isAuthenticated = false;
    } catch (_) {
      _lastRawAuthErrorCode = null;
      _error = 'Unable to sign in right now. Please try again.';
      _isAuthenticated = false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    if (_isLoading) {
      return;
    }
    _setLoading(true);
    try {
      await _service.signUp(name: name, email: email, password: password);
      _isAuthenticated = _service.currentSession != null;
      _lastRawAuthErrorCode = null;
      _error = null;
    } on AuthException catch (error) {
      _lastRawAuthErrorCode = _extractAuthErrorCode(error);
      _error = _mapAuthError(error.message, isSignup: true);
      _isAuthenticated = false;
    } catch (_) {
      _lastRawAuthErrorCode = null;
      _error = 'Unable to create your account right now. Please try again.';
      _isAuthenticated = false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _service.signOut();
  }

  Future<bool> updatePassword(String newPassword) async {
    if (_isLoading) return false;
    _setLoading(true);
    try {
      await _service.updatePassword(newPassword);
      _error = null;
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Unable to update password right now. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Initiates an email change. Returns [true] if the verification emails were
  /// sent successfully. The actual email change only takes effect after the
  /// user clicks the confirmation links in both inboxes (old and new).
  Future<bool> updateEmail(String newEmail) async {
    if (_isLoading) return false;
    _setLoading(true);
    try {
      await _service.updateEmail(newEmail);
      _error = null;
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Unable to update email right now. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _mapAuthError(String message, {required bool isSignup}) {
    final normalized = message.toLowerCase();

    if (normalized.contains('email address') &&
        normalized.contains('invalid')) {
      return 'Please enter a valid email address.';
    }

    if (normalized.contains('rate limit') ||
        normalized.contains('too many') ||
        normalized.contains('over_email_send_rate_limit')) {
      return 'Too many requests. Please wait a bit and try again.';
    }

    return message;
  }

  String? _extractAuthErrorCode(AuthException error) {
    final dynamic dynamicError = error;
    final dynamic code = dynamicError.code;
    if (code is String && code.isNotEmpty) {
      return code;
    }

    final message = error.message.toLowerCase();
    if (message.contains('over_email_send_rate_limit')) {
      return 'over_email_send_rate_limit';
    }

    final statusCode = error.statusCode;
    if (statusCode != null && statusCode.isNotEmpty) {
      return statusCode;
    }

    return null;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
