import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryDarkGreen = Color(0xFF1E522C);
  static const Color secondaryLightGreen = Color(0xFF86B944);
  static const Color sunYellow = Color(0xFFF1BE3E);
  static const Color textBlack = Color(0xFF111111);
  static const Color textGrey = Color(0xFF6E6E6E);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primaryDarkGreen,
        secondary: secondaryLightGreen,
        tertiary: sunYellow,
        background: Colors.white,
        surface: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDarkGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: textBlack, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: textBlack),
        bodyMedium: TextStyle(color: textGrey),
      ),
    );
  }
}