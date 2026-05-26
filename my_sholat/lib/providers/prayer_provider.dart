// lib/providers/prayer_provider.dart
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/prayer_api_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../database/database_helper.dart';

class PrayerProvider extends ChangeNotifier {
  final _api = PrayerApiService();
  final _location = LocationService();
  final _db = DatabaseHelper();
  final _notif = NotificationService();

  DailyPrayers? _todayPrayers;
  LocationResult? _currentLocation;
  bool _isLoading = false;
  String? _error;
  String _cityName = 'Yogyakarta';

  DailyPrayers? get todayPrayers => _todayPrayers;
  LocationResult? get currentLocation => _currentLocation;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get cityName => _cityName;

  PrayerTime? get nextPrayer => _todayPrayers?.nextPrayer;

  Duration? get countdownToNext {
    final next = nextPrayer;
    if (next == null) return null;
    final diff = next.dateTime.difference(DateTime.now());
    return diff.isNegative ? null : diff;
  }

  Future<void> loadPrayers({String? city}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      DailyPrayers? prayers;

      if (city != null) {
        _cityName = city;
        prayers = await _api.fetchByCity(city: city);
      } else {
        final loc = await _location.getCurrentLocation();
        if (loc != null) {
          _currentLocation = loc;
          _cityName = loc.city;
          prayers = await _api.fetchByCoordinates(
            latitude: loc.latitude,
            longitude: loc.longitude,
          );
        } else {
          prayers = await _api.fetchByCity(city: _cityName);
        }
      }

      if (prayers != null) {
        _todayPrayers = prayers;
        await _db.cachePrayerTimes(_cityName, prayers.prayers);
        final settings = UserSettings(city: _cityName);
        await _notif.scheduleAllPrayers(
          prayers.prayers,
          reminderMinutes: settings.reminderMinutes,
        );
      } else {
        _todayPrayers = _api.fallbackYogyakarta;
        _error = 'Gagal memuat jadwal. Menampilkan data lokal.';
      }
    } catch (e) {
      _error = 'Error: $e';
      _todayPrayers ??= _api.fallbackYogyakarta;
    }

    _isLoading = false;
    notifyListeners();
  }

  void markPrayerDone(String prayerName) {
    if (_todayPrayers == null) return;
    final updated = _todayPrayers!.prayers.map((p) {
      if (p.name == prayerName) return p.copyWith(isDone: true);
      return p;
    }).toList();
    _todayPrayers = DailyPrayers(date: _todayPrayers!.date, prayers: updated);
    notifyListeners();
  }
}