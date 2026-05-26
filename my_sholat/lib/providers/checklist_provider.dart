// lib/providers/checklist_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import '../models/models.dart';
import '../database/database_helper.dart';

class ChecklistProvider extends ChangeNotifier {
  final _db = DatabaseHelper();

  List<ChecklistEntry> _todayEntries = [];
  List<DayStats> _weeklyStats = [];
  bool _isLoading = false;
  int _streak = 0;

  List<ChecklistEntry> get todayEntries => _todayEntries;
  List<DayStats> get weeklyStats => _weeklyStats;
  bool get isLoading => _isLoading;
  int get streak => _streak;

  int get completedToday => _todayEntries.where((e) => e.isDone).length;
  double get completionRateToday =>
      _todayEntries.isEmpty ? 0 : completedToday / 5;
  int get lateToday =>
      _todayEntries.where((e) => e.isDone && e.isLate).length;

  // FIX: pakai _safeNotify agar tidak setState during build
  void _safeNotify() {
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) => notifyListeners());
    } else {
      notifyListeners();
    }
  }

  Future<void> loadToday() async {
    _isLoading = true;
    _safeNotify();

    const prayerNames = ['Subuh', 'Dzuhur', 'Ashar', 'Maghrib', 'Isya'];
    final today = DateTime.now();
    final existing = await _db.getChecklistByDate(today);

    final entries = <ChecklistEntry>[];
    for (final name in prayerNames) {
      final found = existing.where((e) => e.prayerName == name).firstOrNull;
      entries.add(found ?? ChecklistEntry(prayerName: name, date: today));
    }

    _todayEntries = entries;
    _isLoading = false;
    _safeNotify();
  }

  Future<void> loadWeeklyStats() async {
    _weeklyStats = await _db.getWeeklyStats();
    _safeNotify();
  }

  Future<void> togglePrayer(String prayerName,
      {required String prayerTime}) async {
    final idx = _todayEntries.indexWhere((e) => e.prayerName == prayerName);
    if (idx == -1) return;

    final entry = _todayEntries[idx];
    final now = DateTime.now();

    bool isLate = false;
    if (!entry.isDone) {
      try {
        final parts = prayerTime.split(':');
        final adzanDt = DateTime(now.year, now.month, now.day,
            int.parse(parts[0]), int.parse(parts[1]));
        isLate = now.isAfter(adzanDt.add(const Duration(minutes: 30)));
      } catch (_) {}
    }

    final updated = entry.copyWith(
      isDone: !entry.isDone,
      completedAt: !entry.isDone ? now : null,
      isLate: !entry.isDone ? isLate : false,
    );

    await _db.upsertChecklist(updated);
    _todayEntries[idx] = updated;
    _safeNotify();

    await _recalculateStreak();
  }

  Future<void> _recalculateStreak() async {
    _streak = await getStreak();
    _safeNotify();
  }

  Future<int> getStreak() async {
    final history = await _db.getLast30Days();
    if (history.isEmpty) return 0;

    int streak = 0;
    var day = DateTime.now();

    while (true) {
      final dayStr = day.toIso8601String().split('T')[0];
      final dayEntries = history
          .where((e) => e.date.toIso8601String().split('T')[0] == dayStr)
          .toList();

      final isToday =
          dayStr == DateTime.now().toIso8601String().split('T')[0];

      if (!isToday &&
          (dayEntries.length < 5 || !dayEntries.every((e) => e.isDone))) {
        break;
      } else if (!isToday) {
        streak++;
      }

      day = day.subtract(const Duration(days: 1));
      if (streak > 365) break;
    }

    return streak;
  }

  Future<List<ChecklistEntry>> getLast30DaysHistory() async {
    return _db.getLast30Days();
  }

  void reset() {
    _todayEntries = [];
    _weeklyStats = [];
    _streak = 0;
    _safeNotify();
  }
}