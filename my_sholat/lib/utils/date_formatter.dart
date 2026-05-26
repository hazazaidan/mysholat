// lib/utils/date_formatter.dart

class DateFormatter {
  DateFormatter._(); // prevent instantiation

  // ─── Month names ──────────────────────────────────────────────────────────

  static const _months = [
    '',
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  static const _monthsShort = [
    '',
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  // ─── Day names ────────────────────────────────────────────────────────────

  static const _days = [
    '', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
  ];

  /// ['Min','Sen','Sel','Rab','Kam','Jum','Sab']
  /// index 0 = Minggu (weekday % 7)
  static const _daysShort = [
    'Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab',
  ];

  static const _hijriMonths = [
    'Muharram', 'Safar', "Rabi'ul Awal", "Rabi'ul Akhir",
    'Jumadil Awal', 'Jumadil Akhir', 'Rajab', "Sya'ban",
    'Ramadhan', 'Syawal', "Dzulqa'dah", 'Dzulhijjah',
  ];

  // ─── Formatters ───────────────────────────────────────────────────────────

  /// Senin, 10 Mei 2025
  static String formatFull(DateTime d) =>
      '${_days[d.weekday]}, ${d.day} ${_months[d.month]} ${d.year}';

  /// 10 Mei 2025
  static String formatDate(DateTime d) =>
      '${d.day} ${_months[d.month]} ${d.year}';

  /// 10 Mei 25
  static String formatDateShort(DateTime d) =>
      '${d.day} ${_monthsShort[d.month]} ${d.year}';

  /// 04:15
  static String formatTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  /// 04:15:36
  static String formatTimeFull(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:'
      '${d.minute.toString().padLeft(2, '0')}:'
      '${d.second.toString().padLeft(2, '0')}';

  /// Sen, Sel, ... (weekday % 7 → 0=Min)
  static String dayShort(DateTime d) => _daysShort[d.weekday % 7];

  /// Senin, Selasa, ...
  static String dayFull(DateTime d) => _days[d.weekday];

  // ─── Hijri (simplified) ───────────────────────────────────────────────────

  /// 12 Dzulqa'dah 1446 H
  /// Catatan: gunakan package `hijri` untuk akurasi produksi
  static String formatHijri(DateTime d) {
    final diff = d.difference(DateTime(2000, 1, 6)).inDays;
    final totalMonths = (diff * 12 / 354.367).floor();
    final hijriYear = 1421 + (totalMonths ~/ 12);
    final hijriMonthIdx = totalMonths % 12;
    final hijriDay = (diff % 30) + 1;
    return '$hijriDay ${_hijriMonths[hijriMonthIdx]} $hijriYear H';
  }

  // ─── Relative ─────────────────────────────────────────────────────────────

  /// "Hari Ini" / "Kemarin" / "Besok" / "10 Mei 2025"
  static String relativeDay(DateTime d) {
    final today = DateTime.now();
    if (isSameDay(d, today)) return 'Hari Ini';
    if (isSameDay(d, today.subtract(const Duration(days: 1)))) return 'Kemarin';
    if (isSameDay(d, today.add(const Duration(days: 1)))) return 'Besok';
    return formatDateShort(d);
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool isToday(DateTime d) => isSameDay(d, DateTime.now());

  static bool isThisWeek(DateTime d) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return d.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        d.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// Countdown format: "01:24:36"
  static String formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}