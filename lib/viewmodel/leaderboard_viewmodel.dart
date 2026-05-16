import 'package:flutter/foundation.dart';
import 'package:green_miles_app/core/app_strings.dart';
import 'package:green_miles_app/data/models/user_model.dart';
import 'package:green_miles_app/data/services/supabase_app_service.dart';

enum LeaderboardPeriod { weekly, monthly, allTime }

class LeaderboardViewModel extends ChangeNotifier {
  LeaderboardViewModel(this._service) {
    fetchLeaderboard();
  }

  final SupabaseAppService _service;

  // Private properties
  LeaderboardPeriod _selectedPeriod = LeaderboardPeriod.weekly;
  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _error;

  // Public getters
  LeaderboardPeriod get selectedPeriod => _selectedPeriod;
  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // --- Public Methods ---

  Future<void> fetchLeaderboard() async {
    _setLoading(true);
    try {
      _users = await _service.fetchLeaderboard(_selectedPeriod);
      _error = null;
    } catch (_) {
      _users = [];
      _error = AppStrings.leaderboardLoadFailed;
    }

    _setLoading(false);
  }

  void setPeriod(LeaderboardPeriod period) {
    if (_selectedPeriod != period) {
      _selectedPeriod = period;
      notifyListeners(); // Notify listeners to update the UI for the selected tab
      fetchLeaderboard(); // Fetch new data for the selected period
    }
  }

  // --- Private Methods ---

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

