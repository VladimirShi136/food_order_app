import 'package:flutter/cupertino.dart';
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

final TextTheme _baseTextTheme = GoogleFonts.interTextTheme(
  ThemeData.dark().textTheme,
).apply(bodyColor: AppColors.textPrimary, displayColor: AppColors.textPrimary);

final TextTheme appTextTheme = _baseTextTheme.copyWith(
  displayLarge: GoogleFonts.montserrat(
    textStyle: _baseTextTheme.displayLarge,
    fontWeight: FontWeight.w800,
  ),
  displayMedium: GoogleFonts.montserrat(
    textStyle: _baseTextTheme.displayMedium,
    fontWeight: FontWeight.w800,
  ),
  displaySmall: GoogleFonts.montserrat(
    textStyle: _baseTextTheme.displaySmall,
    fontWeight: FontWeight.w700,
  ),
  headlineLarge: GoogleFonts.montserrat(
    textStyle: _baseTextTheme.headlineLarge,
    fontWeight: FontWeight.w800,
  ),
  headlineMedium: GoogleFonts.montserrat(
    textStyle: _baseTextTheme.headlineMedium,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.5,
  ),
  headlineSmall: GoogleFonts.montserrat(
    textStyle: _baseTextTheme.headlineSmall,
    fontWeight: FontWeight.w700,
  ),
  titleLarge: GoogleFonts.montserrat(
    textStyle: _baseTextTheme.titleLarge,
    fontWeight: FontWeight.w700,
  ),
  titleMedium: GoogleFonts.montserrat(
    textStyle: _baseTextTheme.titleMedium,
    fontWeight: FontWeight.w700,
  ),
  titleSmall: GoogleFonts.montserrat(
    textStyle: _baseTextTheme.titleSmall,
    fontWeight: FontWeight.w600,
  ),
);

final ThemeData appTheme = ThemeData(
  scaffoldBackgroundColor: Colors.transparent,
  colorScheme: ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.accent,
    surface: AppColors.surface,
  ),
  textTheme: appTextTheme,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.background,
      textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
    ),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    scrolledUnderElevation: 0,
    elevation: 0,
    titleTextStyle: GoogleFonts.montserrat(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w800,
      fontSize: 20,
      letterSpacing: 0.5,
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedLabelStyle: GoogleFonts.inter(
      fontWeight: FontWeight.w600,
      fontSize: 12,
    ),
    unselectedLabelStyle: GoogleFonts.inter(
      fontWeight: FontWeight.w500,
      fontSize: 12,
    ),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: AppColors.surface,
    contentTextStyle: GoogleFonts.inter(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w500,
    ),
    actionTextColor: AppColors.primary,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: AppColors.primary, width: 1),
    ),
  ),
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  ),
);
