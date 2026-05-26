// lib/services/prayer_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/prayer_model.dart';
import '../utils/constants.dart';

class PrayerApiService {
  static const String _baseUrl = AppStrings.aladhanBaseUrl;

  /// Fetch prayer times by city name (Indonesia)
  Future<DailyPrayers?> fetchByCity({
    required String city,
    String country = 'Indonesia',
    DateTime? date,
  }) async {
    final d = date ?? DateTime.now();
    final dateStr = '${d.day.toString().padLeft(2,'0')}-${d.month.toString().padLeft(2,'0')}-${d.year}';
    final url = Uri.parse(
      '$_baseUrl/timingsByCity/$dateStr?city=$city&country=$country&method=11',
    );
    // method=11 = Kemenag Indonesia

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 200) {
          final timings = data['data']['timings'] as Map<String, dynamic>;
          return DailyPrayers.fromAladhan(timings, d);
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('[PrayerApi] Error: $e');
    }
    return null;
  }

  /// Fetch by latitude/longitude (auto location)
  Future<DailyPrayers?> fetchByCoordinates({
    required double latitude,
    required double longitude,
    DateTime? date,
  }) async {
    final d = date ?? DateTime.now();
    final dateStr = '${d.day.toString().padLeft(2,'0')}-${d.month.toString().padLeft(2,'0')}-${d.year}';
    final url = Uri.parse(
      '$_baseUrl/timings/$dateStr?latitude=$latitude&longitude=$longitude&method=11',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 200) {
          final timings = data['data']['timings'] as Map<String, dynamic>;
          return DailyPrayers.fromAladhan(timings, d);
        }
      }
    } catch (e) {
      print('[PrayerApi] Error by coords: $e');
    }
    return null;
  }

  /// Fetch monthly calendar
  Future<List<DailyPrayers>> fetchMonthly({
    required String city,
    int? month,
    int? year,
  }) async {
    final now = DateTime.now();
    final m = month ?? now.month;
    final y = year ?? now.year;
    final url = Uri.parse(
      '$_baseUrl/calendarByCity/$y/$m?city=$city&country=Indonesia&method=11',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 200) {
          final List<dynamic> days = data['data'];
          return days.asMap().entries.map((e) {
            final date = DateTime(y, m, e.key + 1);
            return DailyPrayers.fromAladhan(
              e.value['timings'] as Map<String, dynamic>, date);
          }).toList();
        }
      }
    } catch (e) {
      print('[PrayerApi] Monthly error: $e');
    }
    return [];
  }

  /// Fallback: hardcoded Yogyakarta times (when offline)
  DailyPrayers get fallbackYogyakarta {
    final now = DateTime.now();
    final timings = {
      'Fajr': '04:15', 'Dhuhr': '12:00',
      'Asr': '15:18', 'Maghrib': '17:42', 'Isha': '18:56',
    };
    return DailyPrayers.fromAladhan(timings, now);
  }
}