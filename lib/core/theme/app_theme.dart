import 'package:flutter/material.dart';

import 'package:freelance_front/core/constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.softWhite,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryGold,
        brightness: Brightness.light,
        primary: AppColors.primaryGold,
        secondary: AppColors.chartreuse,
        surface: AppColors.pureWhite,
        onSurface: AppColors.deepBlack,
        error: AppColors.errorRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.pureWhite,
        foregroundColor: AppColors.deepBlack,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.pureWhite,
        elevation: 2,
        margin: EdgeInsets.symmetric(vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGold,
          foregroundColor: AppColors.deepBlack,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.pureWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.neutralGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryGold, width: 2),
        ),
      ),
      textTheme: ThemeData.light().textTheme.apply(
        bodyColor: AppColors.deepBlack,
        displayColor: AppColors.deepBlack,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.deepBlack,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryGold,
        brightness: Brightness.dark,
        primary: AppColors.primaryGold,
        secondary: AppColors.chartreuse,
        surface: AppColors.anthracite,
        onSurface: AppColors.pureWhite,
        error: AppColors.errorRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.deepBlack,
        foregroundColor: AppColors.pureWhite,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.anthracite,
        elevation: 2,
        margin: EdgeInsets.symmetric(vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGold,
          foregroundColor: AppColors.deepBlack,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.anthracite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.neutralGrayDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryGold, width: 2),
        ),
      ),
      textTheme: ThemeData.dark().textTheme.apply(
        bodyColor: AppColors.pureWhite,
        displayColor: AppColors.pureWhite,
      ),
    );
  }
}
