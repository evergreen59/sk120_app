import 'package:flutter/material.dart';

abstract final class AppFonts {
  static const sans = 'AppSans';
}

abstract final class AppColors {
  static const background = Color(0xFF081017);
  static const surface = Color(0xFF101C25);
  static const surfaceRaised = Color(0xFF162631);
  static const border = Color(0xFF29414E);
  static const electricBlue = Color(0xFF4EA1FF);
  static const cyan = Color(0xFF3DE0D0);
  static const green = Color(0xFF65D995);
  static const amber = Color(0xFFFFC857);
  static const red = Color(0xFFFF6B75);
  static const text = Color(0xFFE9F3F7);
  static const muted = Color(0xFF93AAB5);
  static const dim = Color(0xFF647A84);
}

abstract final class AppSpacing {
  static const xs = 6.0;
  static const sm = 10.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

abstract final class AppRadius {
  static const small = BorderRadius.all(Radius.circular(6));
  static const medium = BorderRadius.all(Radius.circular(8));
  static const pill = BorderRadius.all(Radius.circular(20));
}

ThemeData buildAppTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.electricBlue,
        brightness: Brightness.dark,
      ).copyWith(
        surface: AppColors.surface,
        onSurface: AppColors.text,
        primary: AppColors.electricBlue,
        secondary: AppColors.cyan,
        error: AppColors.red,
      );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: AppFonts.sans,
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
      titleMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      ),
      bodyLarge: TextStyle(fontSize: 15, color: AppColors.text),
      bodyMedium: TextStyle(fontSize: 13, color: AppColors.muted),
      labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.text,
      elevation: 0,
      centerTitle: false,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface.withValues(alpha: 0.96),
      indicatorColor: AppColors.electricBlue.withValues(alpha: 0.22),
      labelTextStyle: WidgetStatePropertyAll(
        const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: AppColors.surface.withValues(alpha: 0.96),
      indicatorColor: AppColors.electricBlue.withValues(alpha: 0.22),
      selectedIconTheme: const IconThemeData(color: AppColors.electricBlue),
      unselectedIconTheme: const IconThemeData(color: AppColors.muted),
      selectedLabelTextStyle: const TextStyle(
        color: AppColors.text,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelTextStyle: const TextStyle(color: AppColors.muted),
    ),
    cardTheme: const CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.medium,
        side: BorderSide(color: AppColors.border),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceRaised,
      border: OutlineInputBorder(
        borderRadius: AppRadius.small,
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.small,
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.small,
        borderSide: BorderSide(color: AppColors.electricBlue, width: 1.5),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      space: 1,
      thickness: 1,
    ),
  );
}
