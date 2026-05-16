# Green Miles App

Green Miles is a Flutter application focused on sustainable mobility tracking. It helps users log trips, estimate carbon savings against car travel, compare progress on a leaderboard, and redeem eco rewards.

This repository now includes Supabase integration for authentication, dashboard/profile/leaderboard/rewards data, and trip persistence.

## 1) Project Details

### What the app does
- Onboarding and authentication flow (Supabase auth).
- Home dashboard with weekly carbon savings and daily stats.
- Trip tracking with live location, route plotting, distance, and duration.
- Carbon savings estimation by transport mode.
- Anti-cheat speed checks with configurable strictness.
- Leaderboard, marketplace rewards, and profile stats/history (Supabase-backed).

### Core tech stack
- Flutter (Material)
- Dart SDK `^3.11.1` (from `pubspec.yaml`)
- State management: `provider`
- Mapping and geo:
  - `flutter_map`
  - `latlong2`
  - `location`
- Charts: `fl_chart`
- Fonts and formatting:
  - `google_fonts`
  - `intl`

### Current implementation status
- Architecture pattern: Presentation + `ChangeNotifier` ViewModels.
- Data layer includes a Supabase service used by feature viewmodels.
- Tracking saves completed trips to Supabase.
- Tracking is the most behavior-rich module (live updates + anti-cheat policy).

## 2) File Structure

Top-level layout:

```text
green-miles-app/
  lib/
  assets/
  test/
  android/
  ios/
  web/
  windows/
  macos/
  linux/
  pubspec.yaml
  analysis_options.yaml
```

App source (`lib/`) layout:

```text
lib/
  main.dart                 # App entry point + MultiProvider setup
  core/
    app_strings.dart        # App copy/constants
    app_theme.dart          # Theme definitions
    feature_flags.dart      # Reserved for feature toggles (currently empty)
  data/
    models/
      trip_model.dart
      user_model.dart
      reward_model.dart
      carbon_stat_model.dart
  view/
    onboarding/             # Splash, welcome, sign in/up, permissions
    home/
    leaderboard/
    tracking/
    market/
    profile/
    notifications/
    widgets/                # Shared UI widgets (buttons, nav, etc.)
    main_screen.dart        # Bottom-nav shell
  viewmodel/
    splash_viewmodel.dart
    auth_viewmodel.dart
    home_viewmodel.dart
    tracking_viewmodel.dart
    leaderboard_viewmodel.dart
    market_viewmodel.dart
    profile_viewmodel.dart
    location_permission_viewmodel.dart
```

Key files to start with:
- `lib/main.dart`
- `lib/view/main_screen.dart`
- `lib/viewmodel/tracking_viewmodel.dart`
- `pubspec.yaml`

## 3) Setup, Run, and Build Guidelines

### Prerequisites
Install and verify:
- Flutter SDK (compatible with Dart `3.11.x` constraint)
- Dart SDK (bundled with Flutter)
- Git
- Android toolchain for Android builds (Android Studio + SDK + emulator)
- Xcode for iOS/macOS builds (macOS only)
- Java 17 for Android Gradle build (project uses Java/Kotlin 17 targets)

Useful check command:

```powershell
flutter doctor -v
```

### Initial setup
From repository root:

```powershell
flutter clean
flutter pub get
flutter analyze
```

### Supabase setup (required)
1. Create a Supabase project.
2. Run SQL in `supabase/schema.sql`.
3. Copy your project URL and anon key.
4. Create `.env` in the repo root (you can copy `.env.example`) and set:

```dotenv
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

The app shows a config screen if these keys are missing.

Auth behavior notes:
- `supabase/config.toml` controls local Supabase CLI/dev stack behavior.
- Hosted Supabase projects use Dashboard auth settings (not this repo file).
- For auto-confirm users: in Dashboard go to **Authentication -> Providers -> Email** and disable email confirmation.
- For signup throttling: in Dashboard go to **Authentication -> Rate Limits** and raise/disable the sign-in/sign-up limit for your environment.

### Run in development
List available targets:

```powershell
flutter devices
```

Run on default detected device:

```powershell
flutter run
```

Run on specific platforms:

```powershell
flutter run -d android
flutter run -d chrome
flutter run -d windows
flutter run -d macos
flutter run -d ios
```

### Build outputs
Android APK (release):

```powershell
flutter build apk --release
```

Android App Bundle (Play Store):

```powershell
flutter build appbundle --release
```

iOS (macOS only):

```powershell
flutter build ios --release
```

Web:

```powershell
flutter build web --release
```

Windows:

```powershell
flutter build windows --release
```

macOS:

```powershell
flutter build macos --release
```

Linux:

```powershell
flutter build linux --release
```

### Release/signing notes
- Android release signing is not fully configured for production yet (`android/app/build.gradle.kts` currently points release to debug signing config).
- Configure keystore signing before publishing.
- Bump version in `pubspec.yaml` (`version: x.y.z+build`) before release.

### Location permission configuration
The app uses the `location` package and tracking depends on runtime location access.

#### Android
Ensure these permissions exist in `android/app/src/main/AndroidManifest.xml` under `<manifest>`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

#### iOS
Add usage description keys in `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Green Miles needs your location to track trips and calculate carbon savings.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Green Miles uses location during trips to measure distance accurately.</string>
```

### Testing and quality checks
Run unit/widget tests:

```powershell
flutter test
```

Run static analysis:

```powershell
flutter analyze
```

Format codebase:

```powershell
dart format .
```

## Development Notes
- Several modules currently use delayed mock responses in ViewModels (`home`, `leaderboard`, `market`, `profile`, `auth`, `splash`).
- Replace mock logic with repositories/services when integrating backend APIs.
- The default `test/widget_test.dart` is still the Flutter counter template and does not match current app UI; update it when adding CI checks.