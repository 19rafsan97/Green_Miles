class UserSettingsModel {
  UserSettingsModel({
    required this.pushEnabled,
    required this.emailEnabled,
    required this.weeklySummaryEnabled,
    required this.profileVisible,
  });

  final bool pushEnabled;
  final bool emailEnabled;
  final bool weeklySummaryEnabled;
  final bool profileVisible;

  UserSettingsModel copyWith({
    bool? pushEnabled,
    bool? emailEnabled,
    bool? weeklySummaryEnabled,
    bool? profileVisible,
  }) {
    return UserSettingsModel(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      weeklySummaryEnabled: weeklySummaryEnabled ?? this.weeklySummaryEnabled,
      profileVisible: profileVisible ?? this.profileVisible,
    );
  }

  factory UserSettingsModel.defaults() {
    return UserSettingsModel(
      pushEnabled: true,
      emailEnabled: true,
      weeklySummaryEnabled: true,
      profileVisible: true,
    );
  }

  factory UserSettingsModel.fromSupabase(Map<String, dynamic> data) {
    return UserSettingsModel(
      pushEnabled: data['push_enabled'] != false,
      emailEnabled: data['email_enabled'] != false,
      weeklySummaryEnabled: data['weekly_summary_enabled'] != false,
      profileVisible: data['profile_visible'] != false,
    );
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      'push_enabled': pushEnabled,
      'email_enabled': emailEnabled,
      'weekly_summary_enabled': weeklySummaryEnabled,
      'profile_visible': profileVisible,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}

