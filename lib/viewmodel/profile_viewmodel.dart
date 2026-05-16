import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:green_miles_app/data/models/trip_model.dart';
import 'package:green_miles_app/data/models/user_model.dart';
import 'package:green_miles_app/data/services/supabase_app_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel(this._service) {
    fetchProfileData();
    _authSubscription = _service.authStateChanges.listen((state) {
      if (state.event == AuthChangeEvent.userUpdated) {
        fetchProfileData();
      }
    });
  }

  final SupabaseAppService _service;
  StreamSubscription<AuthState>? _authSubscription;

  UserModel? _user;
  List<TripModel> _tripHistory = [];
  bool _isLoading = false;
  bool _isSavingProfile = false;
  String? _error;
  String? _profileSaveError;

  UserModel? get user => _user;
  List<TripModel> get tripHistory => _tripHistory;
  bool get isLoading => _isLoading;
  bool get isSavingProfile => _isSavingProfile;
  String? get error => _error;
  String? get profileSaveError => _profileSaveError;

  Future<void> fetchProfileData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _service.fetchCurrentUserProfile();
      _tripHistory = await _service.fetchTripHistory();
      _error = null;
    } catch (_) {
      _error = 'Unable to load profile data right now.';
      _tripHistory = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String name,
    required String currentAvatarUrl,
    Uint8List? newAvatarBytes,
    String? newAvatarFileName,
    String? newAvatarContentType,
  }) async {
    if (_isSavingProfile) {
      return false;
    }

    _isSavingProfile = true;
    _profileSaveError = null;
    notifyListeners();

    try {
      String avatarUrlToSave = currentAvatarUrl;

      if (newAvatarBytes != null && newAvatarFileName != null) {
        avatarUrlToSave = await _service.uploadAvatarBytes(
          newAvatarBytes,
          newAvatarFileName,
          contentType: newAvatarContentType,
        );
      }

      final updatedUser = await _service.updateCurrentUserProfile(
        name: name,
        avatarUrl: avatarUrlToSave,
      );
      if (updatedUser == null) {
        _profileSaveError = 'Unable to update profile right now.';
        return false;
      }

      _user = updatedUser;
      return true;
    } catch (e) {
      _profileSaveError = e.toString();
      return false;
    } finally {
      _isSavingProfile = false;
      notifyListeners();
    }
  }
  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

