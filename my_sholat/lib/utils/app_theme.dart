// lib/utils/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

class AppTheme {
  static TextTheme _lightTextTheme() => TextTheme(
    displayLarge:  GoogleFonts.plusJakartaSans(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
    displayMedium: GoogleFonts.plusJakartaSans(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
    bodyLarge:     GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 14),
    bodyMedium:    GoogleFonts.plusJakartaSans(color: AppColors.textMuted, fontSize: 13),
    bodySmall:     GoogleFonts.plusJakartaSans(color: AppColors.textHint, fontSize: 11),
    labelLarge:    GoogleFonts.plusJakartaSans(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
  );

  static TextTheme _darkTextTheme() => TextTheme(
    displayLarge:  GoogleFonts.plusJakartaSans(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w700),
    displayMedium: GoogleFonts.plusJakartaSans(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w600),
    bodyLarge:     GoogleFonts.plusJakartaSans(color: AppColors.darkTextSecondary, fontSize: 14),
    bodyMedium:    GoogleFonts.plusJakartaSans(color: AppColors.darkTextMuted, fontSize: 13),
    bodySmall:     GoogleFonts.plusJakartaSans(color: AppColors.darkTextHint, fontSize: 11),
    labelLarge:    GoogleFonts.plusJakartaSans(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w600),
  );

  static ThemeData dark(Color primaryColor) => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBgDeep,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: Color.lerp(primaryColor, Colors.black, 0.15)!,
      surface: AppColors.darkBgCard,
      onPrimary: Colors.white,
      onSurface: AppColors.darkTextPrimary,
    ),
    textTheme: _darkTextTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkBgMain,
      elevation: 0,
      iconTheme: IconThemeData(color: primaryColor),
      titleTextStyle: GoogleFonts.plusJakartaSans(
        color: AppColors.darkTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkBgMain,
      selectedItemColor: primaryColor,
      unselectedItemColor: AppColors.darkTextFaint,
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
              : AppColors.darkBgCardBorder),
    ),
    dividerColor: AppColors.darkBgCardBorder,
    iconTheme: IconThemeData(color: primaryColor),
  );

  static ThemeData light(Color primaryColor) => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.bgDeep,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: Color.lerp(primaryColor, Colors.black, 0.15)!,
      surface: AppColors.bgCard,
      onPrimary: Colors.white,
      onSurface: AppColors.textPrimary,
    ),
    textTheme: _lightTextTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.bgMain,
      elevation: 0,
      iconTheme: IconThemeData(color: primaryColor),
      titleTextStyle: GoogleFonts.plusJakartaSans(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.bgMain,
      selectedItemColor: primaryColor,
      unselectedItemColor: AppColors.textHint,
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
}