import 'package:flutter/foundation.dart';
import 'package:green_miles_app/data/models/reward_model.dart';
import 'package:green_miles_app/data/services/supabase_app_service.dart';

class MarketViewModel extends ChangeNotifier {
  MarketViewModel(this._service) {
    fetchRewards();
  }

  final SupabaseAppService _service;

  List<RewardModel> _rewards = [];
  bool _isLoading = false;
  String? _error;

  List<RewardModel> get rewards => _rewards;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchRewards() async {
    _isLoading = true;
    notifyListeners();

    try {
      _rewards = await _service.fetchRewards();
      _error = null;
    } catch (_) {
      _rewards = [];
      _error = 'Unable to load rewards right now.';
    }

    _isLoading = false;
    notifyListeners();
  }
}

