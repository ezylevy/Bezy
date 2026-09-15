import 'package:flutter/material.dart';

/// Design tokens and styles for Math Path Adventure.
class AppTheme {
  // Background & Surfaces
  static const Color bgDark = Color(0xFF0B0F19);
  static const Color surfaceDark = Color(0xFF161F30);
  static const Color surfaceElevated = Color(0xFF1E293B);
  static const Color cardBorder = Color(0xFF334155);

  // Gameplay Accent Colors
  static const Color startGreen = Color(0xFF10B981);
  static const Color targetPink = Color(0xFFF43F5E);
  static const Color pathCyan = Color(0xFF06B6D4);
  static const Color gold = Color(0xFFFBBF24);
  static const Color wallGray = Color(0xFF475569);
  static const Color wallDark = Color(0xFF334155);
  static const Color trampolineOrange = Color(0xFFFF7A00);
  static const Color smartGatePurple = Color(0xFF9333EA);

  // Text Colors
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      colorScheme: const ColorScheme.dark(
        primary: pathCyan,
        secondary: gold,
        surface: surfaceDark,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: pathCyan,
          foregroundColor: Colors.black,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
