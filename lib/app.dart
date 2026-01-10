import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart';
import 'core/auth_gate/auth_gate.dart';
import 'services/habit_service.dart';
import 'services/user_service.dart';

class HabitFlowApp extends StatelessWidget {
  const HabitFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => HabitService()),
        Provider(create: (_) => UserService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,

        routes: AppRoutes.routes,        // ← Register all routes here
        home: const AuthGate(),          // ← Decide start based on auth
      ),
    );
  }
}