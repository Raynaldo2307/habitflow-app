import 'package:flutter/material.dart';

// Screens
import '../features/onboarding/onboarding_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/services/forgot_password_screen.dart';
import '../features/habits/home_screen.dart';
import '../features/habits/add_edit_habit_screen.dart';
import '../features/habits/habit_details_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/profile/edit_profile_screen.dart';
import '../core/layout/main_layout.dart';

class AppRoutes {
  // Auth & Onboarding
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Main Layout
  static const String mainLayout = '/main';

  // Habits
  static const String home = '/home';
  static const String addHabit = '/habits/add';
  static const String habitDetails = '/habits/details';

  // Progress
  static const String progress = '/progress';

  // Profile
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';

  static final Map<String, WidgetBuilder> routes = {
    onboarding: (context) => const OnboardingScreen(),
    login: (context) => const LoginScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),
    register: (context) => const RegisterScreen(),
    mainLayout: (context) => const MainLayout(),

    // Habit Screens
    home: (context) => const HomeScreen(),
    addHabit: (context) => const AddEditHabitScreen(),
    habitDetails: (context) => const HabitDetailsScreen(),

    // Progress & Profile
    progress: (context) => const ProgressScreen(),
    profile: (context) => const ProfileScreen(),
    editProfile: (context) => const EditProfileScreen(),
  };
}
