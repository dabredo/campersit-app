import 'package:flutter/material.dart';

class AppColors {
  static const Color mainBackground = Color(0xFFF4F7F4);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color primaryAccent = Color(0xFF1E6B37);
  static const Color secondaryAccent = Color(0xFF68B04D);
  static const Color securityHighlight = Color(0xFF1E6B37);
  static const Color borderLight = Color(0xFFE2ECE4);
  static const Color textPrimary = Color(0xFF102216);
  static const Color textSecondary = Color(0xFF5A7163);
}

class AppRadius {
  static const double roundedXl = 12.0;
  static const double rounded2Xl = 16.0;

  static const BorderRadius borderXl = BorderRadius.all(Radius.circular(roundedXl));
  static const BorderRadius border2Xl = BorderRadius.all(Radius.circular(rounded2Xl));
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.mainBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryAccent,
        secondary: AppColors.secondaryAccent,
        surface: AppColors.cardSurface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.mainBackground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.border2Xl,
          side: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryAccent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.borderXl,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardSurface,
        labelStyle: TextStyle(color: AppColors.textSecondary),
        hintStyle: TextStyle(color: AppColors.textSecondary),
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: AppRadius.borderXl,
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderXl,
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderXl,
          borderSide: BorderSide(color: AppColors.primaryAccent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderXl,
          borderSide: BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderXl,
          borderSide: BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
      useMaterial3: true,
    );
  }
}
