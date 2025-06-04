import 'package:flutter/material.dart';

ThemeData customTheme() {
  return ThemeData(
    colorScheme: ColorScheme.dark(
        primary: Color(0xFF6A1B9A),     // Dark Purple
        secondary: Color(0xFF9C27B0),   // Medium Purple
        surface: Color(0xFFFFFFFF),  // Dark Background
        tertiary: Color(0xFF000000)
    ),
    textTheme: TextTheme(
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.white70,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
    ),
  );
}