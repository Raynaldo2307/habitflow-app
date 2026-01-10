import 'package:flutter/material.dart';

class AppTheme {
  // ───────────── Colors ─────────────
  static const Color primaryColor = Color(0xFF1CA7EC); // Ocean blue
  static const Color backgroundColor = Color(0xFFF4F8FB); // Soft light
  static const Color accentColor = Color(0xFFE0F2FE); // Light blue
  static const Color textColor = Color(0xFF0F172A); // Dark text

  // ───────────── Input Decoration (Reusable for TextFields) ─────────────
  static const InputDecoration inputDecoration = InputDecoration(
    border: OutlineInputBorder(),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(width: 2),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
  // ───────────── Light Theme ─────────────
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,

      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,

      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.light,
        seedColor: primaryColor,
        secondary: accentColor,
      ),

      // ───────────── Typography ─────────────
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        bodyMedium: TextStyle(fontSize: 16, color: textColor),
      ),

      // ───────────── AppBar ─────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),

      // ───────────── Floating Button ─────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        elevation: 2,
      ),
    );
  }
}
