import 'package:flutter/material.dart';

class AppTheme {
  // Brand colors
  static const Color primaryViolet = Color(0xFF6D5DF6); // Modern SaaS primary violet
  static const Color secondaryViolet = Color(0xFF8B80F9); // Soft Indigo-Violet matching primary
  static const Color accentViolet = Color(0xFFF1F0FF); // Extremely light violet for highlights
  
  // Backgrounds & Surface
  static const Color backgroundLight = Color(0xFFF8FAFC); // Page background (Slate 50 / Light Gray)
  static const Color surfaceLight = Colors.white; // Pure white cards (#FFFFFF)
  static const Color borderLight = Color(0xFFE2E8F0); // Sleek Slate-200 border
  
  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A); // Deep Slate (Slate 900)
  static const Color textSecondary = Color(0xFF475569); // Slate Gray (Slate 600)
  static const Color textMuted = Color(0xFF94A3B8); // Muted Slate (Slate 400)

  // Premium Shadows
  static List<BoxShadow> get premiumShadow => [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.04),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.02),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.03),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  // Light Theme Configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primaryViolet,
        onPrimary: Colors.white,
        secondary: secondaryViolet,
        onSecondary: Colors.white,
        error: Color(0xFFDC2626), // Tailind red 600
        onError: Colors.white,
        surface: surfaceLight,
        onSurface: textPrimary,
        surfaceContainerHighest: Color(0xFFF3F4F6),
        outline: borderLight,
      ),
      scaffoldBackgroundColor: backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: textPrimary, fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -0.8),
        headlineMedium: TextStyle(color: textPrimary, fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        titleLarge: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.3),
        titleMedium: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.2),
        bodyLarge: TextStyle(color: textPrimary, fontSize: 15, letterSpacing: -0.1),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 13, letterSpacing: -0.1),
        labelLarge: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryViolet,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryViolet,
          side: const BorderSide(color: borderLight, width: 1.5),
          elevation: 0,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white, // Solid white input background for maximum contrast
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        hintStyle: const TextStyle(color: textMuted, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: borderLight, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: borderLight, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: primaryViolet, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.8),
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceLight, // Solid white card background (#FFFFFF) for premium SaaS contrast
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderLight, width: 1.5),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderLight,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
