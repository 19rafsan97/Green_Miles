import 'package:flutter/foundation.dart';
import 'package:green_miles_app/core/app_strings.dart';
import 'package:green_miles_app/data/models/user_settings_model.dart';
import 'package:green_miles_app/data/services/supabase_app_service.dart';

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel(this._service) {
    loadSettings();
  }

  final SupabaseAppService _service;

  UserSettingsModel _settings = UserSettingsModel.defaults();
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  UserSettingsModel get settings => _settings;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;

  Future<void> loadSettings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _settings = await _service.fetchCurrentUserSettings();
    } catch (_) {
      _error = AppStrings.settingsLoadFailed;
    }

    _isLoading = false;
    notifyListeners();
  }

  void updatePushEnabled(bool value) {
    _settings = _settings.copyWith(pushEnabled: value);
    notifyListeners();
  }

  void updateEmailEnabled(bool value) {
    _settings = _settings.copyWith(emailEnabled: value);
    notifyListeners();
  }

  void updateWeeklySummaryEnabled(bool value) {
    _settings = _settings.copyWith(weeklySummaryEnabled: value);
    notifyListeners();
  }

  void updateProfileVisible(bool value) {
    _settings = _settings.copyWith(profileVisible: value);
    notifyListeners();
  }

  Future<bool> saveSettings() async {
    if (_isSaving) {
      return false;
    }

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      _settings = await _service.saveCurrentUserSettings(_settings);
      return true;
    } catch (_) {
      _error = AppStrings.settingsSaveFailed;
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}

