// lib/utils/prayer_time_helper.dart
import '../models/prayer_model.dart';

class PrayerTimeHelper {
  /// Format Duration to HH:MM:SS string
  static String formatCountdown(Duration duration) {
    final h = duration.inHours.toString().padLeft(2, '0');
    final m = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final s = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  /// Get next prayer from a list
  static PrayerTime? getNextPrayer(List<PrayerTime> prayers) {
    final now = DateTime.now();
    try {
      return prayers.firstWhere((p) => p.dateTime.isAfter(now));
    } catch (_) {
      return null;
    }
  }

  /// Get current/active prayer (within its window)
  static PrayerTime? getCurrentPrayer(List<PrayerTime> prayers) {
    final now = DateTime.now();
    PrayerTime? current;
    for (int i = 0; i < prayers.length; i++) {
      if (prayers[i].dateTime.isBefore(now)) {
        current = prayers[i];
      } else {
        break;
      }
    }
    return current;
  }

  /// Check if a prayer time is within 15 minutes
  static bool isApproaching(PrayerTime prayer, {int minutes = 15}) {
    final diff = prayer.dateTime.difference(DateTime.now());
    return diff.inMinutes >= 0 && diff.inMinutes <= minutes;
  }

  /// Get duration until next prayer
  static Duration? countdownToNext(List<PrayerTime> prayers) {
    final next = getNextPrayer(prayers);
    if (next == null) return null;
    final diff = next.dateTime.difference(DateTime.now());
    return diff.isNegative ? null : diff;
  }

  /// Determine if a prayer completion was late
  /// Late = completed more than 30 minutes after adzan
  static bool isPrayerLate(DateTime prayerTime, DateTime completedAt) {
    final diff = completedAt.difference(prayerTime);
    return diff.inMinutes > 30;
  }
}


// lib/utils/date_formatter.dart
class DateFormatter {
  static const _months = [
    '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  static const _monthsShort = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];

  static const _days = [
    '', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
  ];

  static const _daysShort = [
    'Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'
  ];

  static String formatFull(DateTime d) =>
      '${_days[d.weekday]}, ${d.day} ${_months[d.month]} ${d.year}';

  static String formatDate(DateTime d) =>
      '${d.day} ${_months[d.month]} ${d.year}';

  static String formatDateShort(DateTime d) =>
      '${d.day} ${_monthsShort[d.month]} ${d.year}';

  static String formatTime(DateTime d) =>
      '${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';

  static String dayShort(DateTime d) => _daysShort[d.weekday % 7];

  static String formatHijri(DateTime d) {
    // Simplified approximation — use hijri package in production
    const hijriMonths = [
      'Muharram', 'Safar', 'Rabi\'ul Awal', 'Rabi\'ul Akhir',
      'Jumadil Awal', 'Jumadil Akhir', 'Rajab', 'Sya\'ban',
      'Ramadhan', 'Syawal', 'Dzulqa\'dah', 'Dzulhijjah',
    ];
    final diff = d.difference(DateTime(2000, 1, 6)).inDays;
    final totalHijriMonths = (diff * 12 / 354.367).floor();
    final hijriYear = 1421 + (totalHijriMonths ~/ 12);
    final hijriMonth = totalHijriMonths % 12;
    final hijriDay = (diff % 30) + 1;
    return '$hijriDay ${hijriMonths[hijriMonth]} $hijriYear H';
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool isToday(DateTime d) => isSameDay(d, DateTime.now());

  static String relativeDay(DateTime d) {
    final today = DateTime.now();
    if (isSameDay(d, today)) return 'Hari Ini';
    if (isSameDay(d, today.subtract(const Duration(days: 1)))) return 'Kemarin';
    if (isSameDay(d, today.add(const Duration(days: 1)))) return 'Besok';
    return formatDateShort(d);
  }
}