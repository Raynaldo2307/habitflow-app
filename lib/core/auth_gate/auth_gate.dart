import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/login_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../layout/main_layout.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasSeenOnboarding(),
      builder: (context, onboardingSnapshot) {
        // Still loading onboarding state
        if (onboardingSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final hasSeenOnboarding = onboardingSnapshot.data ?? false;

        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, authSnapshot) {
            // Still checking auth state
            if (authSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final user = authSnapshot.data;

            // 🔹 1. User has NOT seen onboarding
            if (!hasSeenOnboarding) {
              return const OnboardingScreen();
            }

            // 🔹 2. User has seen onboarding BUT is not logged in
            if (user == null) {
              return const LoginScreen();
            }

            // 🔹 3. User is logged in
            return const MainLayout();
          },
        );
      },
    );
  }

  Future<bool> _hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('seenOnboarding') ?? false;
  }
}