import 'package:flutter/material.dart';

class AppTheme {
  static const Color emeraldGreen = Color(0xFF10B981);

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: emeraldGreen,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.black,
      canvasColor: Colors.black,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.4,
        ),
      ),
    );
  }
}
