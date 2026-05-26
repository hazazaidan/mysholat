// lib/utils/app_theme.dart
import 'package:flutter/material.dart';
import 'constants.dart';

class AppTheme {
  static ThemeData dark(Color primaryColor) => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bgDeep,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: Color.lerp(primaryColor, Colors.black, 0.15)!,
      surface: AppColors.bgCard,
      onPrimary: Colors.white,
      onSurface: AppColors.textPrimary,
    ),
    fontFamily: 'Poppins',
    textTheme: const TextTheme(
      displayLarge:  TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
      displayMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
      bodyLarge:     TextStyle(color: AppColors.textSecondary, fontSize: 14),
      bodyMedium:    TextStyle(color: AppColors.textMuted, fontSize: 13),
      bodySmall:     TextStyle(color: AppColors.textHint, fontSize: 11),
      labelLarge:    TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.bgMain,
      elevation: 0,
      iconTheme: IconThemeData(color: primaryColor),
      titleTextStyle: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.bgMain,
      selectedItemColor: primaryColor,
      unselectedItemColor: AppColors.textFaint,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? primaryColor : Colors.grey),
      trackColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected)
              ? primaryColor.withValues(alpha: 0.4)
              : AppColors.bgCardBorder),
    ),
    dividerColor: AppColors.bgCardBorder,
    iconTheme: IconThemeData(color: primaryColor),
  );

  static ThemeData light(Color primaryColor) => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF0FAF4),
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: Color.lerp(primaryColor, Colors.black, 0.15)!,
      surface: Colors.white,
    ),
    fontFamily: 'Poppins',
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: primaryColor),
      titleTextStyle: const TextStyle(
        color: Color(0xFF0D2A18),
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
      ),
    ),
  );
}