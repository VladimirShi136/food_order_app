import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF141414);
  static const surface = Color(0xFF1E1E1E);
  static const primary = Color(0xFFF5B301);
  static const accent = Color(0xFFD98E04);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB0B0B0);
}

TextStyle _montserrat({
  required FontWeight weight,
  double? fontSize,
  Color? color,
  double? letterSpacing,
}) {
  return TextStyle(
    fontFamily: 'Montserrat',
    fontWeight: weight,
    fontSize: fontSize,
    color: color ?? AppColors.textPrimary,
    letterSpacing: letterSpacing,
  );
}

TextStyle _inter({
  FontWeight weight = FontWeight.w400,
  double? fontSize,
  Color? color,
}) {
  return TextStyle(
    fontFamily: 'Inter',
    fontWeight: weight,
    fontSize: fontSize,
    color: color ?? AppColors.textPrimary,
  );
}

final TextTheme appTextTheme = TextTheme(
  displayLarge: _montserrat(weight: FontWeight.w800, fontSize: 57),
  displayMedium: _montserrat(weight: FontWeight.w800, fontSize: 45),
  displaySmall: _montserrat(weight: FontWeight.w700, fontSize: 36),
  headlineLarge: _montserrat(weight: FontWeight.w800, fontSize: 32),
  headlineMedium: _montserrat(
    weight: FontWeight.w800,
    fontSize: 24,
    letterSpacing: 0.5,
  ),
  headlineSmall: _montserrat(weight: FontWeight.w700, fontSize: 22),
  titleLarge: _montserrat(weight: FontWeight.w700, fontSize: 20),
  titleMedium: _montserrat(weight: FontWeight.w700, fontSize: 16),
  titleSmall: _montserrat(weight: FontWeight.w600, fontSize: 14),
  bodyLarge: _inter(fontSize: 16),
  bodyMedium: _inter(fontSize: 14, color: AppColors.textSecondary),
  bodySmall: _inter(fontSize: 12, color: AppColors.textSecondary),
  labelLarge: _inter(weight: FontWeight.w600, fontSize: 14),
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
      textStyle: _inter(weight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
    ),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    scrolledUnderElevation: 0,
    elevation: 0,
    titleTextStyle: _montserrat(
      weight: FontWeight.w800,
      fontSize: 20,
      letterSpacing: 0.5,
    ),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: AppColors.surface,
    contentTextStyle: _inter(weight: FontWeight.w500),
    actionTextColor: AppColors.primary,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: AppColors.primary, width: 1),
    ),
  ),
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: {
      TargetPlatform.android: _NoFlashSlideTransitionsBuilder(),
      TargetPlatform.iOS: _NoFlashSlideTransitionsBuilder(),
    },
  ),
);

class _NoFlashSlideTransitionsBuilder extends PageTransitionsBuilder {
  const _NoFlashSlideTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final incomingCurve = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );
    final outgoingCurve = CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeInCubic,
    );

    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(-1, 0),
      ).animate(outgoingCurve),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(incomingCurve),
        child: child,
      ),
    );
  }
}
