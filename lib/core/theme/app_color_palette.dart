import 'package:flutter/material.dart';

class AppColorPalette {
  // Primary Color Schemes
  static final ColorScheme lightColorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primaryBlue,
    primary: AppColors.primaryBlue,
    secondary: AppColors.accentAmber,
    background: AppColors.backgroundLight,
    surface: Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.black,
  );

  static final ColorScheme darkColorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primaryBlue,
    brightness: Brightness.dark,
    primary: AppColors.primaryBlue,
    secondary: AppColors.accentAmber,
    background: AppColors.backgroundDark,
    surface: AppColors.surfaceDark,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
  );


  static final ColorScheme purpleColorScheme = ColorScheme.fromSeed(
    seedColor: Colors.deepPurpleAccent,
    brightness: Brightness.light,
    primary: AppColors.primaryBlue,
    secondary: AppColors.accentAmber,
    surface: AppColors.surfaceDark,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
  );

  // Custom Color Extensions
  static final Map<String, Color> categoryColors = {
    'Electronics': Color(0xFF2196F3),
    'Fashion': Color(0xFFE91E63),
    'Home': Color(0xFF4CAF50),
    'Books': Color(0xFF9C27B0),
    'Sports': Color(0xFFFF9800),
  };
}

class AppColors {
  // Primary Colors
  static const Color primaryOrange = Color(0xFFFF5722);
  static const Color accentAmber = Color(0xFFFFC107);

  static const Color primaryBlue = Color(0xFF032B88);

  // Background Colors
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);

  // Surface Colors
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Text Colors
  static const Color textLight = Color(0xFF333333);
  static const Color textDark = Color(0xFFE0E0E0);



  static const Color yellow = Color(0xFFFFD801);
  static const Color purpleDeep = Color(0xFF28006C);





  // Gradient Colors
  static final Gradient primaryGradient = LinearGradient(
    colors: [primaryOrange.withValues(alpha: 0.8), primaryOrange.withValues(alpha: 0.6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
