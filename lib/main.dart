import 'dart:async';
import 'package:flutter/material.dart';
import 'package:green_miles_app/core/app_strings.dart';
import 'package:green_miles_app/core/app_theme.dart';
import 'package:green_miles_app/core/connectivity_service.dart';
import 'package:green_miles_app/core/local_notification_service.dart';
import 'package:green_miles_app/core/supabase_env.dart';
import 'package:green_miles_app/data/services/offline_trip_queue.dart';
import 'package:green_miles_app/data/services/supabase_app_service.dart';
import 'package:green_miles_app/view/onboarding/auth_gate.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'viewmodel/auth_viewmodel.dart';
import 'viewmodel/home_viewmodel.dart';
import 'viewmodel/leaderboard_viewmodel.dart';
import 'viewmodel/market_viewmodel.dart';
import 'viewmodel/notifications_viewmodel.dart';
import 'viewmodel/profile_viewmodel.dart';
import 'viewmodel/settings_viewmodel.dart';
import 'viewmodel/tracking_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalNotificationService.instance.initialize();
  await LocalNotificationService.instance.requestPermissions();

  try {
    await SupabaseEnv.load();
  } catch (_) {
    // Missing or unreadable .env falls back to the config missing screen.
  }

  if (!SupabaseEnv.isConfigured) {
    runApp(const SupabaseConfigMissingApp());
    return;
  }

  await Supabase.initialize(url: SupabaseEnv.url, anonKey: SupabaseEnv.anonKey);

  final offlineQueue = await OfflineTripQueue.create();
  final service = SupabaseAppService(Supabase.instance.client, offlineQueue);

  // Set up connectivity monitoring for automatic offline trip sync.
  final connectivityService = ConnectivityService();
  connectivityService.onlineStream.listen((online) {
    if (online) {
      unawaited(service.syncPendingTrips());
    }
  });

  // Attempt to sync any trips that were queued in a previous session.
  unawaited(service.syncPendingTrips());

  runApp(AppBootstrap(service: service));
}

class AppBootstrap extends StatelessWidget {
  const AppBootstrap({super.key, required this.service});

  final SupabaseAppService service;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<SupabaseAppService>.value(value: service),
        ChangeNotifierProvider(create: (_) => HomeViewModel(service)),
        ChangeNotifierProvider(create: (_) => LeaderboardViewModel(service)),
        ChangeNotifierProvider(create: (_) => TrackingViewModel(service)),
        ChangeNotifierProvider(create: (_) => MarketViewModel(service)),
        ChangeNotifierProvider(create: (_) => ProfileViewModel(service)),
        ChangeNotifierProvider(create: (_) => NotificationsViewModel(service)),
        ChangeNotifierProvider(create: (_) => SettingsViewModel(service)),
        ChangeNotifierProvider(create: (_) => AuthViewModel(service)),
      ],
      child: MyApp(service: service),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.service});

  final SupabaseAppService service;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      theme: AppTheme.lightTheme,
      home: AuthGate(service: service),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SupabaseConfigMissingApp extends StatelessWidget {
  const SupabaseConfigMissingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Supabase is not configured. Create a .env file with SUPABASE_URL=... and SUPABASE_ANON_KEY=...',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
      ),
    );
  }
}
