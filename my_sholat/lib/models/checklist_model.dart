// lib/models/checklist_model.dart

class ChecklistEntry {
  final int? id;
  final String prayerName;
  final DateTime date;
  final bool isDone;
  final DateTime? completedAt;
  final bool isLate;

  const ChecklistEntry({
    this.id,
    required this.prayerName,
    required this.date,
    this.isDone = false,
    this.completedAt,
    this.isLate = false,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'prayer_name': prayerName,
    'date': date.toIso8601String().split('T')[0],
    'is_done': isDone ? 1 : 0,
    'completed_at': completedAt?.toIso8601String(),
    'is_late': isLate ? 1 : 0,
  };

  factory ChecklistEntry.fromMap(Map<String, dynamic> m) => ChecklistEntry(
    id: m['id'],
    prayerName: m['prayer_name'],
    date: DateTime.parse(m['date']),
    isDone: m['is_done'] == 1,
    completedAt: m['completed_at'] != null ? DateTime.parse(m['completed_at']) : null,
    isLate: m['is_late'] == 1,
  );

  ChecklistEntry copyWith({bool? isDone, DateTime? completedAt, bool? isLate}) =>
      ChecklistEntry(
        id: id, prayerName: prayerName, date: date,
        isDone: isDone ?? this.isDone,
        completedAt: completedAt ?? this.completedAt,
        isLate: isLate ?? this.isLate,
      );
}

class WeeklyStats {
  final List<DayStats> days;
  WeeklyStats({required this.days});

  double get averageCompletion => days.isEmpty
      ? 0
      : days.map((d) => d.completionRate).reduce((a, b) => a + b) / days.length;
}

class DayStats {
  final DateTime date;
  final int completed;
  final int total;
  DayStats({required this.date, required this.completed, required this.total});
  double get completionRate => total == 0 ? 0 : completed / total;
  String get dayLabel {
    const labels = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
    return labels[date.weekday % 7];
  }
}