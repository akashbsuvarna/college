import 'package:flutter/material.dart';

class AppTheme {
  // Main background colors
  static const Color surfaceDark = Colors.white;
  static const Color sidebarBg = Colors.white;
  static const Color surfaceCard = Colors.white;
  static const Color surfaceCardHover = Color(0xFFF3F4F6);
  
  // Dividers and Borders
  static const Color dividerColor = Color(0xFFE5E7EB);
  
  // Text colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF4B5563);
  static const Color textMuted = Color(0xFF9CA3AF);
  
  // Brand / Primary Colors
  static const Color primaryNavy = Colors.indigo;
  
  // Accent colors
  static const Color accentIndigo = Colors.indigo;
  static const Color accentRed = Colors.red;
  static const Color accentGreen = Colors.green;
  static const Color accentPurple = Colors.purple;
  static const Color accentCyan = Colors.cyan;
  static const Color accentOrange = Colors.orange;
  
  // Gradients
  static const List<Color> gradientBlue = [Colors.blue, Colors.blueAccent];
  static const List<Color> gradientPurple = [Colors.purple, Colors.purpleAccent];
  static const List<Color> gradientCyan = [Colors.cyan, Colors.cyanAccent];
  static const List<Color> gradientGreen = [Colors.green, Colors.greenAccent];
  static const List<Color> gradientOrange = [Colors.orange, Colors.orangeAccent];

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: surfaceDark,
      fontFamily: 'Roboto',

      colorScheme: const ColorScheme.light(
        primary: primaryNavy,
        secondary: accentPurple,
        surface: surfaceDark,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
        headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: textSecondary),
        bodyMedium: TextStyle(color: textSecondary),
        labelLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
      ),

      cardTheme: const CardThemeData(
        color: surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: dividerColor),
        ),
      ),

      dividerTheme: const DividerThemeData(color: dividerColor),

      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDark,
        foregroundColor: textPrimary,
        elevation: 0,
        shape: Border(bottom: BorderSide(color: dividerColor, width: 1)),
      ),

      useMaterial3: true,
    );
  }
}