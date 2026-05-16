import 'package:flutter/material.dart';
import 'package:green_miles_app/data/models/carbon_stat_model.dart';
import 'package:green_miles_app/data/models/user_model.dart';
import 'package:green_miles_app/data/services/supabase_app_service.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel(this._service) {
    fetchDashboardData();
  }

  final SupabaseAppService _service;

  // Private properties
  UserModel? _user;
  double _weeklyCo2Saved = 0.0;
  List<CarbonStatModel> _dailyStats = [];
  bool _isLoading = false;
  String? _error;

  // Public getters
  UserModel? get user => _user;
  double get weeklyCo2Saved => _weeklyCo2Saved;
  List<CarbonStatModel> get dailyStats => _dailyStats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // --- Public Methods ---

  Future<void> fetchDashboardData() async {
    _setLoading(true);

    try {
      final profile = await _service.fetchCurrentUserProfile();
      final weekly = await _service.fetchWeeklyCo2Saved();
      final stats = await _service.fetchLast7DaysStats();
      _user = profile;
      _weeklyCo2Saved = weekly;
      _dailyStats = stats;
      _error = null;
    } catch (_) {
      _error = 'Unable to load dashboard data right now.';
      _dailyStats = [];
      _weeklyCo2Saved = 0;
    }

    _setLoading(false);
  }

  // --- Private Methods ---

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

