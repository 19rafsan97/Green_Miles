import 'dart:typed_data';
import 'package:green_miles_app/data/models/carbon_stat_model.dart';
import 'package:green_miles_app/data/models/app_notification_model.dart';
import 'package:green_miles_app/data/models/reward_model.dart';
import 'package:green_miles_app/data/models/trip_model.dart';
import 'package:green_miles_app/data/models/user_model.dart';
import 'package:green_miles_app/data/models/user_settings_model.dart';
import 'package:green_miles_app/data/services/offline_trip_queue.dart';
import 'package:green_miles_app/data/services/supabase_auth_service.dart';
import 'package:green_miles_app/data/services/supabase_leaderboard_service.dart';
import 'package:green_miles_app/data/services/supabase_notification_service.dart';
import 'package:green_miles_app/data/services/supabase_profile_service.dart';
import 'package:green_miles_app/data/services/supabase_reward_service.dart';
import 'package:green_miles_app/data/services/supabase_settings_service.dart';
import 'package:green_miles_app/data/services/supabase_trip_service.dart';
import 'package:green_miles_app/viewmodel/leaderboard_viewmodel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAppService {
  SupabaseAppService(SupabaseClient client, OfflineTripQueue offlineQueue)
    : _authService = SupabaseAuthService(client),
      _profileService = SupabaseProfileService(client),
      _tripService = SupabaseTripService(client, offlineQueue),
      _leaderboardService = SupabaseLeaderboardService(client),
      _rewardService = SupabaseRewardService(client),
      _notificationService = SupabaseNotificationService(client),
      _settingsService = SupabaseSettingsService(client) {
    // Listen for auth state changes to keep the profile row in sync with auth.users
    _authService.authStateChanges.listen((state) {
      if (state.event == AuthChangeEvent.userUpdated ||
          state.event == AuthChangeEvent.signedIn) {
        syncEmailToProfile();
      }
    });
  }

  final SupabaseAuthService _authService;
  final SupabaseProfileService _profileService;
  final SupabaseTripService _tripService;
  final SupabaseLeaderboardService _leaderboardService;
  final SupabaseRewardService _rewardService;
  final SupabaseNotificationService _notificationService;
  final SupabaseSettingsService _settingsService;

  User? get currentUser => _authService.currentUser;
  Session? get currentSession => _authService.currentSession;
  Stream<AuthState> get authStateChanges => _authService.authStateChanges;

  Future<void> signIn({required String email, required String password}) {
    return _authService.signIn(email: email, password: password);
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) {
    return _authService.signUp(name: name, email: email, password: password);
  }

  Future<void> signOut() {
    return _authService.signOut();
  }

  Future<void> updatePassword(String newPassword) {
    return _authService.updatePassword(newPassword);
  }

  Future<void> updateEmail(String newEmail) {
    return _authService.updateEmail(newEmail);
  }

  Future<UserModel?> fetchCurrentUserProfile() {
    return _profileService.fetchCurrentUserProfile();
  }

  Future<UserModel?> updateCurrentUserProfile({
    required String name,
    required String avatarUrl,
  }) {
    return _profileService.updateCurrentUserProfile(
      name: name,
      avatarUrl: avatarUrl,
    );
  }

  Future<String> uploadAvatarBytes(Uint8List bytes, String fileName, {String? contentType}) {
    return _profileService.uploadAvatarBytes(bytes, fileName, contentType: contentType);
  }

  Future<void> syncEmailToProfile() {
    return _profileService.syncEmailToProfile();
  }

  Future<List<TripModel>> fetchTripHistory({int limit = 20}) {
    return _tripService.fetchTripHistory(limit: limit);
  }

  Future<void> saveTrip({
    required TransportMode mode,
    required DateTime startTime,
    required DateTime endTime,
    required double distanceKm,
    required double co2SavedKg,
  }) {
    return _tripService.saveTrip(
      mode: mode,
      startTime: startTime,
      endTime: endTime,
      distanceKm: distanceKm,
      co2SavedKg: co2SavedKg,
    );
  }

  Future<double> fetchWeeklyCo2Saved() {
    return _tripService.fetchWeeklyCo2Saved();
  }

  Future<List<CarbonStatModel>> fetchLast7DaysStats() {
    return _tripService.fetchLast7DaysStats();
  }

  Future<List<UserModel>> fetchLeaderboard(LeaderboardPeriod period) {
    return _leaderboardService.fetchLeaderboard(period);
  }

  Future<List<RewardModel>> fetchRewards() {
    return _rewardService.fetchRewards();
  }

  Future<List<AppNotificationModel>> fetchNotifications({int limit = 50}) {
    return _notificationService.fetchNotifications(limit: limit);
  }

  Future<void> markNotificationRead(int notificationId) {
    return _notificationService.markNotificationRead(notificationId);
  }

  Future<void> markAllNotificationsRead() {
    return _notificationService.markAllNotificationsRead();
  }

  Future<UserSettingsModel> fetchCurrentUserSettings() {
    return _settingsService.fetchCurrentUserSettings();
  }

  Future<UserSettingsModel> saveCurrentUserSettings(UserSettingsModel settings) {
    return _settingsService.saveCurrentUserSettings(settings);
  }

  /// Upload all trips that were saved locally while the device was offline.
  Future<void> syncPendingTrips() {
    return _tripService.syncPendingTrips();
  }
}
