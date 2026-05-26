// lib/services/ai_recommendation_service.dart
import '../models/models.dart';

class AiRecommendationService {
  /// Analyze checklist history and generate smart advice
  List<AiAdvice> generateAdvice(List<ChecklistEntry> history) {
    final advices = <AiAdvice>[];
    final now = DateTime.now();

    // Group by prayer name
    final Map<String, List<ChecklistEntry>> byPrayer = {};
    for (final e in history) {
      byPrayer.putIfAbsent(e.prayerName, () => []).add(e);
    }

    // Check for consistently late prayers
    for (final entry in byPrayer.entries) {
      final done = entry.value.where((e) => e.isDone).toList();
      final late = done.where((e) => e.isLate).length;
      if (done.isNotEmpty && late / done.length > 0.5) {
        advices.add(AiAdvice(
          id: 'late_${entry.key}',
          type: AdviceType.reminder,
          title: 'Konsistensi ${entry.key}',
          description:
              'Kamu sering terlambat ${entry.key}. Aktifkan pengingat 10 menit sebelum adzan agar tidak terlewat.',
          actionLabel: 'Aktifkan Pengingat ${entry.key}',
          targetPrayer: entry.key,
          createdAt: now,
        ));
      }
    }

    // Check for missed prayers
    final recentMissed = <String>[];
    for (final entry in byPrayer.entries) {
      final recent = entry.value.where(
        (e) => e.date.isAfter(now.subtract(const Duration(days: 7)))).toList();
      final missedCount = recent.where((e) => !e.isDone).length;
      if (recent.length >= 3 && missedCount >= 2) {
        recentMissed.add(entry.key);
      }
    }
    if (recentMissed.isNotEmpty) {
      advices.add(AiAdvice(
        id: 'missed_${recentMissed.join('_')}',
        type: AdviceType.consistency,
        title: 'Jaga Konsistensi Ibadah',
        description:
            '${recentMissed.join(", ")} sering terlewat minggu ini. Yuk tingkatkan konsistensi sholatmu!',
        actionLabel: 'Lihat Statistik',
        createdAt: now,
      ));
    }

    // Streak achievement
    final streak = _calculateStreak(history);
    if (streak >= 3) {
      advices.insert(
        0,
        AiAdvice(
          id: 'streak_$streak',
          type: AdviceType.achievement,
          title: 'MasyaAllah! $streak Hari Berturut',
          description: 'Kamu sudah konsisten $streak hari berturut-turut. Pertahankan semangatmu!',
          createdAt: now,
        ),
      );
    }

    // Always add static tips
    advices.addAll(_staticTips());

    return advices;
  }

  int _calculateStreak(List<ChecklistEntry> history) {
    if (history.isEmpty) return 0;
    final byDate = <String, List<ChecklistEntry>>{};
    for (final e in history) {
      final key = e.date.toIso8601String().split('T')[0];
      byDate.putIfAbsent(key, () => []).add(e);
    }

    int streak = 0;
    var day = DateTime.now();
    while (true) {
      final key = day.toIso8601String().split('T')[0];
      final entries = byDate[key] ?? [];
      final allDone = entries.length == 5 && entries.every((e) => e.isDone);
      if (!allDone) break;
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  List<AiAdvice> _staticTips() {
    final now = DateTime.now();
    return [
      AiAdvice(
        id: 'tip_istighfar',
        type: AdviceType.tips,
        title: 'Perbanyak Istighfar',
        description: 'Perbanyak istighfar di waktu pagi, agar hati tenang sepanjang hari.',
        createdAt: now,
      ),
      AiAdvice(
        id: 'tip_jamaah',
        type: AdviceType.tips,
        title: 'Sholat Berjamaah',
        description: 'Usahakan sholat berjamaah minimal sekali sehari untuk menambah pahala 27 derajat.',
        createdAt: now,
      ),
      AiAdvice(
        id: 'tip_sunnah',
        type: AdviceType.tips,
        title: 'Sholat Sunnah Rawatib',
        description: 'Sholat sunnah sebelum/sesudah sholat fardhu sangat dianjurkan untuk melengkapi ibadah.',
        createdAt: now,
      ),
    ];
  }
}