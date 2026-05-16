import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:green_miles_app/data/services/supabase_app_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashViewModel extends ChangeNotifier {
  SplashViewModel(this._service) {
    _authSubscription = _service.authStateChanges.listen(_onAuthChanged);
    _init();
  }

  final SupabaseAppService _service;
  StreamSubscription<AuthState>? _authSubscription;

  bool _isChecking = true;
  bool _isAuthenticated = false;

  bool get isChecking => _isChecking;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> _init() async {
    _isAuthenticated = _service.currentSession != null;
    await Future.delayed(const Duration(milliseconds: 700));
    _isChecking = false;
    notifyListeners();
  }

  void _onAuthChanged(AuthState state) {
    _isAuthenticated = state.session != null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

