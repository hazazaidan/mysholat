// lib/utils/constants.dart
import 'package:flutter/material.dart';

class AppColors {
  // ── Primary — Emerald premium ──
  static const Color primary      = Color(0xFF059669);
  static const Color primaryDark  = Color(0xFF047857);
  static const Color primaryLight = Color(0xFF10B981);

  // ── Light Mode Backgrounds ──
  static const Color bgDeep             = Color(0xFFF0F4F2);
  static const Color bgMain             = Color(0xFFFFFFFF);
  static const Color bgCard             = Color(0xFFFFFFFF);
  static const Color bgCardActive       = Color(0xFFD1FAE5);
  static const Color bgCardBorder       = Color(0xFFE2E8F0);
  static const Color bgCardBorderActive = Color(0xFFA7F3D0);

  // ── Light Mode Text ──
  static const Color textPrimary   = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF334155);
  static const Color textMuted     = Color(0xFF64748B);
  static const Color textHint      = Color(0xFF94A3B8);
  static const Color textFaint     = Color(0xFFCBD5E1);

  // ── Dark Mode Backgrounds ──
  static const Color darkBgDeep             = Color(0xFF080E0B);
  static const Color darkBgMain             = Color(0xFF0F1510);
  static const Color darkBgCard             = Color(0xFF172019);
  static const Color darkBgCardActive       = Color(0xFF0E2318);
  static const Color darkBgCardBorder       = Color(0xFF1E2D22);
  static const Color darkBgCardBorderActive = Color(0xFF245233);

  // ── Dark Mode Text ──
  static const Color darkTextPrimary   = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkTextMuted     = Color(0xFF94A3B8);
  static const Color darkTextHint      = Color(0xFF64748B);
  static const Color darkTextFaint     = Color(0xFF334155);

  // ── Semantic ──
  static const Color success = Color(0xFF059669);
  static const Color warning = Color(0xFFCA8A04);
  static const Color error   = Color(0xFFEF4444);
  static const Color info    = Color(0xFF0369A1);

  // ── Context-aware helpers ──
  static Color bg(BuildContext context, {bool card = false, bool active = false}) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    if (active) return dark ? darkBgCardActive : bgCardActive;
    if (card)   return dark ? darkBgCard       : bgCard;
    return dark ? darkBgDeep : bgDeep;
  }

  static Color border(BuildContext context, {bool active = false}) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return active
        ? (dark ? darkBgCardBorderActive : bgCardBorderActive)
        : (dark ? darkBgCardBorder       : bgCardBorder);
  }

  static Color text(BuildContext context, {String level = 'primary'}) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    switch (level) {
      case 'secondary': return dark ? darkTextSecondary : textSecondary;
      case 'muted':     return dark ? darkTextMuted     : textMuted;
      case 'hint':      return dark ? darkTextHint      : textHint;
      case 'faint':     return dark ? darkTextFaint     : textFaint;
      default:          return dark ? darkTextPrimary   : textPrimary;
    }
  }
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