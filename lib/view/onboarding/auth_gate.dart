import 'package:flutter/material.dart';
import 'package:green_miles_app/data/services/supabase_app_service.dart';
import 'package:green_miles_app/view/main_screen.dart';
import 'package:green_miles_app/view/onboarding/welcome_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.service});

  final SupabaseAppService service;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: service.authStateChanges,
      initialData: AuthState(
        AuthChangeEvent.initialSession,
        service.currentSession,
      ),
      builder: (context, snapshot) {
        final session = snapshot.data?.session ?? service.currentSession;
        if (session != null) {
          return const MainScreen();
        }
        return const WelcomeScreen();
      },
    );
  }
}
