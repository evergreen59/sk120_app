import 'package:flutter/material.dart';

abstract final class AppFonts {
  static const sans = 'AppSans';
}

abstract final class AppColors {
  static const background = Color(0xFF05070F);
  static const backgroundMid = Color(0xFF0A0F1E);
  static const backgroundLight = Color(0xFF0E1730);
  static const surface = Color(0x0FFFFFFF);
  static const surfaceStrong = Color(0x1AFFFFFF);
  static const surfaceRaised = Color(0xFF111A30);
  static const border = Color(0x1FFFFFFF);
  static const highlight = Color(0x2EFFFFFF);
  static const electricBlue = Color(0xFF3B82F6);
  static const blueBright = Color(0xFF4F9DFF);
  static const cyan = Color(0xFF22D3EE);
  static const green = Color(0xFF34D399);
  static const amber = Color(0xFFFBBF24);
  static const red = Color(0xFFF87171);
  static const purple = Color(0xFFA78BFA);
  static const text = Color(0xFFF4F7FF);
  static const muted = Color(0xFF9FB0CC);
  static const dim = Color(0xFF6B7A96);
}

abstract final class AppSpacing {
  static const xs = 6.0;
  static const sm = 10.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

abstract final class AppRadius {
  static const small = BorderRadius.all(Radius.circular(12));
  static const medium = BorderRadius.all(Radius.circular(16));
  static const large = BorderRadius.all(Radius.circular(24));
  static const sheet = BorderRadius.vertical(top: Radius.circular(28));
  static const pill = BorderRadius.all(Radius.circular(999));
}

abstract final class AppShadows {
  static const glass = [
    BoxShadow(color: Color(0x55000000), blurRadius: 32, offset: Offset(0, 12)),
    BoxShadow(color: Color(0x12FFFFFF), blurRadius: 0, spreadRadius: 0.5),
  ];
}

ThemeData buildAppTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.electricBlue,
        brightness: Brightness.dark,
      ).copyWith(
        surface: AppColors.backgroundMid,
        onSurface: AppColors.text,
        primary: AppColors.electricBlue,
        secondary: AppColors.cyan,
        error: AppColors.red,
      );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Colors.transparent,
    fontFamily: AppFonts.sans,
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 30,
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
      backgroundColor: Colors.transparent,
      indicatorColor: AppColors.electricBlue.withValues(alpha: 0.22),
      labelTextStyle: WidgetStatePropertyAll(
        const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: Colors.transparent,
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
      color: Colors.transparent,
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
