// lib/providers/settings_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';

class SettingsProvider extends ChangeNotifier {
  UserSettings _settings = const UserSettings();
  bool _loaded = false;

  Future<List<PrayerTime>> Function()? onGetPrayers;

  UserSettings get settings             => _settings;
  bool         get loaded               => _loaded;
  bool         get darkMode             => _settings.darkMode;
  String       get city                 => _settings.city;
  int          get reminderMinutes      => _settings.reminderMinutes;
  bool         get vibration            => _settings.vibration;
  bool         get notificationsEnabled => _settings.notificationsEnabled;
  String       get adzanSound           => _settings.adzanSound;


  Color get themeColor => AppColors.primary;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _settings = UserSettings(
      city:                 prefs.getString(AppStrings.keyCity)        ?? 'Yogyakarta',
      darkMode:             prefs.getBool(AppStrings.keyDarkMode)       ?? true,
      adzanSound:           prefs.getString(AppStrings.keyAdzanSound)   ?? 'mekah',
      reminderMinutes:      prefs.getInt(AppStrings.keyReminderMinutes) ?? 10,
      vibration:            prefs.getBool(AppStrings.keyVibration)      ?? true,
      notificationsEnabled: prefs.getBool('notifications_enabled')      ?? true,
    );
    _loaded = true;
    notifyListeners();
  }

  Future<void> updateCity(String city) async {
    _settings = _settings.copyWith(city: city);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppStrings.keyCity, city);
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _settings = _settings.copyWith(darkMode: !_settings.darkMode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppStrings.keyDarkMode, _settings.darkMode);
    notifyListeners();
  }

  Future<void> setReminderMinutes(int minutes) async {
    _settings = _settings.copyWith(reminderMinutes: minutes);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppStrings.keyReminderMinutes, minutes);
    notifyListeners();
    await _rescheduleNotifications();
  }

  Future<void> toggleVibration() async {
    _settings = _settings.copyWith(vibration: !_settings.vibration);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppStrings.keyVibration, _settings.vibration);
    notifyListeners();
    await _rescheduleNotifications();
  }

  Future<void> toggleNotifications() async {
    _settings = _settings.copyWith(
        notificationsEnabled: !_settings.notificationsEnabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _settings.notificationsEnabled);
    notifyListeners();

    if (!_settings.notificationsEnabled) {
      await NotificationService().cancelAll();
    } else {
      await _rescheduleNotifications();
    }
  }

  Future<void> setAdzanSound(String sound) async {
    _settings = _settings.copyWith(adzanSound: sound);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppStrings.keyAdzanSound, sound);
    notifyListeners();
  }

  Future<void> setCoordinates(double lat, double lng) async {
    _settings = _settings.copyWith(latitude: lat, longitude: lng);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('latitude', lat);
    await prefs.setDouble('longitude', lng);
    notifyListeners();
  }

  Future<void> resetToDefault() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await NotificationService().cancelAll();
    _settings = const UserSettings();
    notifyListeners();
  }

  Future<void> _rescheduleNotifications() async {
    if (onGetPrayers == null) return;
    final prayers = await onGetPrayers!();
    if (prayers.isEmpty) return;

    final notif = NotificationService();
    if (_settings.vibration && _settings.notificationsEnabled) {
      await notif.scheduleAllPrayers(
        prayers,
        reminderMinutes: _settings.reminderMinutes,
      );
    } else {
      await notif.cancelAll();
    }
  }
}