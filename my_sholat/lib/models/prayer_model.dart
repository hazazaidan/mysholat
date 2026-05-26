// lib/models/prayer_model.dart

class PrayerTime {
  final String name;
  final String time;       // "04:15"
  final DateTime dateTime;
  final bool isNext;
  bool isDone;

  PrayerTime({
    required this.name,
    required this.time,
    required this.dateTime,
    this.isNext = false,
    this.isDone = false,
  });

  factory PrayerTime.fromAladhan(String name, String timeStr, DateTime date) {
    // FIX: strip suffix seperti " (WIB)", " +07", "(WIB)" sebelum parse
    // Contoh input: "04:15", "04:15 (WIB)", "04:15 +07"
    final clean = timeStr.trim().split(' ')[0].split('(')[0].trim();
    final parts = clean.split(':');
    final hour   = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;

    // DateTime tanpa timezone = local time device (sudah benar)
    final dt = DateTime(date.year, date.month, date.day, hour, minute);

    final hh = hour.toString().padLeft(2, '0');
    final mm = minute.toString().padLeft(2, '0');

    return PrayerTime(name: name, time: '$hh:$mm', dateTime: dt);
  }

  PrayerTime copyWith({bool? isDone, bool? isNext}) => PrayerTime(
    name: name, time: time, dateTime: dateTime,
    isNext: isNext ?? this.isNext,
    isDone: isDone ?? this.isDone,
  );

  Map<String, dynamic> toMap() => {
    'name': name,
    'time': time,
    'date': dateTime.toIso8601String(),
    'isDone': isDone ? 1 : 0,
  };

  factory PrayerTime.fromMap(Map<String, dynamic> map) => PrayerTime(
    name: map['name'],
    time: map['time'],
    dateTime: DateTime.parse(map['date']),
    isDone: map['isDone'] == 1,
  );
}

class DailyPrayers {
  final DateTime date;
  final List<PrayerTime> prayers;

  DailyPrayers({required this.date, required this.prayers});

  int get completedCount => prayers.where((p) => p.isDone).length;
  double get completionRate =>
      prayers.isEmpty ? 0 : completedCount / prayers.length;

  PrayerTime? get nextPrayer {
    final now = DateTime.now();
    try {
      return prayers.firstWhere((p) => p.dateTime.isAfter(now) && !p.isDone);
    } catch (_) {
      return null;
    }
  }

  factory DailyPrayers.fromAladhan(
      Map<String, dynamic> timings, DateTime date) {
    const prayerKeys  = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    const prayerNames = ['Subuh', 'Dzuhur', 'Ashar', 'Maghrib', 'Isya'];
    final prayers = <PrayerTime>[];
    for (int i = 0; i < prayerKeys.length; i++) {
      final raw = timings[prayerKeys[i]];
      if (raw != null) {
        prayers.add(
          PrayerTime.fromAladhan(prayerNames[i], raw.toString(), date),
        );
      }
    }
    return DailyPrayers(date: date, prayers: prayers);
  }
}