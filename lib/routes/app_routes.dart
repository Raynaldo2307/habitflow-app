import 'package:flutter/material.dart';

import '../features/onboarding/onboarding_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/habits/home_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/profile/profile_screen.dart';

class AppRoutes {
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const progress = '/progress';
  static const profile = '/profile';

  static final routes = <String, WidgetBuilder>{
    onboarding: (context) => const OnboardingScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    home: (context) => const HomeScreen(),
    progress: (context) => const ProgressScreen(),
    profile: (context) => const ProfileScreen(),
  };
}
 