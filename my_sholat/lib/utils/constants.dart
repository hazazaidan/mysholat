// lib/utils/constants.dart
import 'package:flutter/material.dart';

class AppColors {
  // Kembalikan ke const — dynamic color dihandle via Theme, bukan static field
  static const Color primary      = Color(0xFF10B981);
  static const Color primaryDark  = Color(0xFF059669);
  static const Color primaryLight = Color(0xFF34D399);

  static const Color bgDeep             = Color(0xFF0A0F0A);
  static const Color bgMain             = Color(0xFF0D1A0F);
  static const Color bgCard             = Color(0xFF0F1A0F);
  static const Color bgCardActive       = Color(0xFF0F2A1A);
  static const Color bgCardBorder       = Color(0xFF1E3A2A);
  static const Color bgCardBorderActive = Color(0xFF1E5A34);

  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFD4E8DC);
  static const Color textMuted     = Color(0xFF9AB8A8);
  static const Color textHint      = Color(0xFF6B9E7A);
  static const Color textFaint     = Color(0xFF4A7A5A);

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFCA8A04);
  static const Color error   = Color(0xFFEF4444);
  static const Color info    = Color(0xFF6EC8F0);
}

class AppStrings {
  static const String appName  = 'MySholat';
  static const String tagline  = 'Teman ibadahmu setiap hari';
  static const List<String> prayerNames = [
    'Subuh', 'Dzuhur', 'Ashar', 'Maghrib', 'Isya'
  ];
  static const String aladhanBaseUrl     = 'https://api.aladhan.com/v1';
  static const String defaultCity        = 'Yogyakarta';
  static const String defaultCountry     = 'Indonesia';
  static const String keyCity            = 'selected_city';
  static const String keyDarkMode        = 'dark_mode';
  static const String keyAdzanSound      = 'adzan_sound';
  static const String keyReminderMinutes = 'reminder_minutes';
  static const String keyVibration       = 'vibration';
  static const String keyOnboarded       = 'onboarded';
  static const String keyThemeColor      = 'theme_color';
}

class AppDimensions {
  static const double radiusSm     = 10.0;
  static const double radiusMd     = 14.0;
  static const double radiusLg     = 18.0;
  static const double radiusXl     = 24.0;
  static const double radiusCircle = 100.0;
  static const double paddingXs    = 8.0;
  static const double paddingSm    = 12.0;
  static const double paddingMd    = 16.0;
  static const double paddingLg    = 20.0;
  static const double paddingXl    = 24.0;
}

class AppDurations {
  static const Duration fast   = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 350);
  static const Duration slow   = Duration(milliseconds: 600);
  static const Duration splash = Duration(milliseconds: 2500);
}

class IndonesianCities {
  static const List<String> cities = [
    'Yogyakarta', 'Jakarta', 'Surabaya', 'Bandung', 'Medan',
    'Semarang', 'Makassar', 'Palembang', 'Denpasar', 'Malang',
    'Batam', 'Pekanbaru', 'Banjarmasin', 'Pontianak', 'Manado',
    'Samarinda', 'Balikpapan', 'Padang', 'Aceh', 'Jayapura',
    'Solo', 'Bogor', 'Depok', 'Tangerang', 'Bekasi',
    'Kendal', 'Purwokerto', 'Batang',
  ];
}