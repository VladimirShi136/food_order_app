import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const background = Color(0xFF141414);
  static const surface = Color(0xFF1E1E1E);
  static const primary = Color(0xFFF5B301);
  static const accent = Color(0xFFD98E04);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB0B0B0);
}

final ThemeData appTheme = ThemeData(
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.accent,
    surface: AppColors.surface,
  ),
  textTheme: TextTheme(
    headlineMedium: GoogleFonts.montserrat(
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
      letterSpacing: 0.5,
    ),
    titleMedium: GoogleFonts.montserrat(
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    bodyMedium: GoogleFonts.inter(color: AppColors.textSecondary),
    labelLarge: GoogleFonts.inter(
      fontWeight: FontWeight.w600,
      color: AppColors.background,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.background,
    elevation: 0,
  ),
);
