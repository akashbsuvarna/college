import 'package:flutter/material.dart';

class AppTheme {
  // Main background colors
  static const Color surfaceDark = Color(0xFFF8F9FC);
  static const Color sidebarBg = Colors.white;
  static const Color surfaceCard = Colors.white;
  static const Color surfaceCardHover = Color(0xFFF3F4F6);
  
  // Dividers and Borders
  static const Color dividerColor = Color(0xFFE5E7EB);
  
  // Text colors
  static const Color textPrimary = Color(0xFF1E1B4B);
  static const Color textSecondary = Color(0xFF4B5563);
  static const Color textMuted = Color(0xFF9CA3AF);
  
  // Brand / Primary Colors
  static const Color primaryNavy = Color(0xFF1E1B4B);
  
  // Accent colors
  static const Color accentIndigo = Color(0xFF6366F1);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentOrange = Color(0xFFF59E0B);
  
  // Gradients
  static const List<Color> gradientBlue = [Color(0xFF6366F1), Color(0xFF4F46E5)];
  static const List<Color> gradientPurple = [Color(0xFF8B5CF6), Color(0xFF7C3AED)];
  static const List<Color> gradientCyan = [Color(0xFF06B6D4), Color(0xFF0891B2)];
  static const List<Color> gradientGreen = [Color(0xFF10B981), Color(0xFF059669)];
  static const List<Color> gradientOrange = [Color(0xFFF59E0B), Color(0xFFD97706)];


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