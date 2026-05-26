// lib/database/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'mysholat.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE checklist (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        prayer_name TEXT NOT NULL,
        date TEXT NOT NULL,
        is_done INTEGER DEFAULT 0,
        completed_at TEXT,
        is_late INTEGER DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE prayer_cache (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        city TEXT NOT NULL,
        date TEXT NOT NULL,
        prayer_name TEXT NOT NULL,
        time TEXT NOT NULL
      )
    ''');
  }

  // ─── CHECKLIST ─────────────────────────────────────────────────────────────

  Future<int> upsertChecklist(ChecklistEntry entry) async {
    final db = await database;
    final existing = await db.query(
      'checklist',
      where: 'prayer_name = ? AND date = ?',
      whereArgs: [entry.prayerName, entry.date.toIso8601String().split('T')[0]],
    );
    if (existing.isEmpty) {
      return db.insert('checklist', entry.toMap());
    } else {
      await db.update(
        'checklist',
        entry.toMap(),
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
      return existing.first['id'] as int;
    }
  }

  Future<List<ChecklistEntry>> getChecklistByDate(DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];
    final results = await db.query(
      'checklist',
      where: 'date = ?',
      whereArgs: [dateStr],
      orderBy: 'id ASC',
    );
    return results.map(ChecklistEntry.fromMap).toList();
  }

  Future<List<ChecklistEntry>> getChecklistRange(DateTime from, DateTime to) async {
    final db = await database;
    final results = await db.query(
      'checklist',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [
        from.toIso8601String().split('T')[0],
        to.toIso8601String().split('T')[0],
      ],
      orderBy: 'date ASC',
    );
    return results.map(ChecklistEntry.fromMap).toList();
  }

  Future<List<ChecklistEntry>> getLast30Days() async {
    final to = DateTime.now();
    final from = to.subtract(const Duration(days: 30));
    return getChecklistRange(from, to);
  }

  /// Get weekly stats (last 7 days)
  Future<List<DayStats>> getWeeklyStats() async {
    final stats = <DayStats>[];
    final today = DateTime.now();
    // Start from Monday of this week
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));

    for (int i = 0; i < 7; i++) {
      final day = startOfWeek.add(Duration(days: i));
      final entries = await getChecklistByDate(day);
      stats.add(DayStats(
        date: day,
        completed: entries.where((e) => e.isDone).length,
        total: 5,
      ));
    }
    return stats;
  }

  // ─── PRAYER CACHE ──────────────────────────────────────────────────────────

  Future<void> cachePrayerTimes(String city, List<PrayerTime> prayers) async {
    final db = await database;
    final dateStr = DateTime.now().toIso8601String().split('T')[0];
    await db.delete('prayer_cache', where: 'city = ? AND date = ?', whereArgs: [city, dateStr]);
    for (final p in prayers) {
      await db.insert('prayer_cache', {
        'city': city, 'date': dateStr,
        'prayer_name': p.name, 'time': p.time,
      });
    }
  }

  Future<List<Map<String, dynamic>>?> getCachedPrayerTimes(String city) async {
    final db = await database;
    final dateStr = DateTime.now().toIso8601String().split('T')[0];
    final results = await db.query(
      'prayer_cache',
      where: 'city = ? AND date = ?',
      whereArgs: [city, dateStr],
    );
    return results.isEmpty ? null : results;
  }
}