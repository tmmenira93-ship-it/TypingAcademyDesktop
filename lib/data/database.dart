import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../core/constants.dart';
import '../models/attempt.dart';
import '../models/key_stat.dart';
import '../models/settings.dart';

class AppDatabase {
  AppDatabase({Database? database, this.directoryOverride}) : _database = database;

  final String? directoryOverride;
  Database? _database;

  static bool _ffiReady = false;

  static void ensureFfi() {
    if (_ffiReady) {
      return;
    }
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    _ffiReady = true;
  }

  Future<Database> get db async {
    if (_database != null) {
      return _database!;
    }
    ensureFfi();
    final dir = directoryOverride ?? await _defaultDirectory();
    await Directory(dir).create(recursive: true);
    final path = p.join(dir, AppConstants.dbFileName);
    _database = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: AppConstants.dbVersion,
        onCreate: (db, version) async {
          await _createSchema(db);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await db.execute('ALTER TABLE settings ADD COLUMN show_keyboard INTEGER NOT NULL DEFAULT 1');
            await db.execute('ALTER TABLE settings ADD COLUMN show_live_stats INTEGER NOT NULL DEFAULT 1');
            await db.execute('ALTER TABLE settings ADD COLUMN allow_backspace INTEGER NOT NULL DEFAULT 1');
          }
          if (oldVersion < 3) {
            await db.execute('ALTER TABLE settings ADD COLUMN block_on_error INTEGER NOT NULL DEFAULT 0');
            await db.execute(_keyStatsSql);
          }
          if (oldVersion < 4) {
            await db.execute('ALTER TABLE settings ADD COLUMN show_hands INTEGER NOT NULL DEFAULT 1');
            await db.execute('ALTER TABLE settings ADD COLUMN key_sounds INTEGER NOT NULL DEFAULT 0');
            await db.execute('ALTER TABLE settings ADD COLUMN game_best INTEGER NOT NULL DEFAULT 0');
          }
          if (oldVersion < 5) {
            await db.execute('ALTER TABLE settings ADD COLUMN voice_over INTEGER NOT NULL DEFAULT 0');
            await db.execute(_replaysSql);
            await db.execute(_gameScoresSql);
          }
        },
      ),
    );
    return _database!;
  }

  Future<String> _defaultDirectory() async {
    if (Platform.isWindows) {
      final appData = Platform.environment['APPDATA'];
      if (appData != null && appData.isNotEmpty) {
        return p.join(appData, 'TypingAcademy');
      }
    }
    if (Platform.isMacOS) {
      final home = Platform.environment['HOME'] ?? '.';
      return p.join(home, 'Library', 'Application Support', 'TypingAcademy');
    }
    final home = Platform.environment['HOME'] ?? '.';
    return p.join(home, '.local', 'share', 'typing_academy');
  }

  Future<void> _createSchema(Database db) async {
    await db.execute('''
CREATE TABLE settings (
  id INTEGER PRIMARY KEY CHECK (id = 1),
  language_code TEXT NOT NULL,
  keyboard_layout TEXT NOT NULL,
  theme_mode TEXT NOT NULL,
  font_scale REAL NOT NULL,
  last_lesson_id TEXT,
  show_keyboard INTEGER NOT NULL DEFAULT 1,
  show_live_stats INTEGER NOT NULL DEFAULT 1,
  allow_backspace INTEGER NOT NULL DEFAULT 1,
  block_on_error INTEGER NOT NULL DEFAULT 0,
  show_hands INTEGER NOT NULL DEFAULT 1,
  key_sounds INTEGER NOT NULL DEFAULT 0,
  game_best INTEGER NOT NULL DEFAULT 0,
  voice_over INTEGER NOT NULL DEFAULT 0
)
''');
    await db.execute('''
CREATE TABLE attempts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  lesson_id TEXT NOT NULL,
  started_at TEXT NOT NULL,
  finished_at TEXT NOT NULL,
  duration_ms INTEGER NOT NULL,
  wpm REAL NOT NULL,
  accuracy REAL NOT NULL,
  errors INTEGER NOT NULL,
  stars INTEGER NOT NULL,
  completed INTEGER NOT NULL
)
''');
    await db.execute('''
CREATE TABLE achievements (
  id TEXT PRIMARY KEY,
  unlocked_at TEXT NOT NULL
)
''');
    await db.execute(_keyStatsSql);
    await db.execute(_replaysSql);
    await db.execute(_gameScoresSql);
    await db.insert('settings', const AppSettings().toMap()..['id'] = 1);
  }

  Future<AppSettings> loadSettings() async {
    final rows = await (await db).query('settings', where: 'id = 1');
    if (rows.isEmpty) {
      return const AppSettings();
    }
    return AppSettings.fromMap(rows.first);
  }

  Future<void> saveSettings(AppSettings settings) async {
    await (await db).update('settings', settings.toMap(), where: 'id = 1');
  }

  Future<int> insertAttempt(LessonAttempt attempt) async {
    final database = await db;
    return database.transaction<int>((txn) async {
      return txn.insert('attempts', attempt.toMap()..remove('id'));
    });
  }

  Future<List<LessonAttempt>> attemptsFor(String lessonId) async {
    final rows = await (await db).query(
      'attempts',
      where: 'lesson_id = ?',
      whereArgs: [lessonId],
      orderBy: 'finished_at DESC',
    );
    return rows.map(LessonAttempt.fromMap).toList();
  }

  Future<List<LessonAttempt>> allAttempts() async {
    final rows = await (await db).query('attempts', orderBy: 'finished_at DESC');
    return rows.map(LessonAttempt.fromMap).toList();
  }

  Future<LessonProgress?> progressFor(String lessonId) async {
    final rows = await (await db).rawQuery('''
SELECT
  lesson_id,
  MAX(wpm) AS best_wpm,
  MAX(accuracy) AS best_accuracy,
  MAX(stars) AS best_stars,
  COUNT(*) AS attempts,
  MAX(completed) AS completed,
  MAX(finished_at) AS last_attempt_at
FROM attempts
WHERE lesson_id = ?
''', [lessonId]);
    if (rows.isEmpty || rows.first['attempts'] == 0) {
      return null;
    }
    final row = rows.first;
    return LessonProgress(
      lessonId: lessonId,
      bestWpm: (row['best_wpm'] as num?)?.toDouble() ?? 0,
      bestAccuracy: (row['best_accuracy'] as num?)?.toDouble() ?? 0,
      bestStars: (row['best_stars'] as num?)?.toInt() ?? 0,
      attempts: (row['attempts'] as num?)?.toInt() ?? 0,
      completed: ((row['completed'] as int?) ?? 0) == 1,
      lastAttemptAt: row['last_attempt_at'] == null
          ? null
          : DateTime.tryParse(row['last_attempt_at'] as String),
    );
  }

  Future<Map<String, LessonProgress>> allProgress() async {
    final rows = await (await db).rawQuery('''
SELECT
  lesson_id,
  MAX(wpm) AS best_wpm,
  MAX(accuracy) AS best_accuracy,
  MAX(stars) AS best_stars,
  COUNT(*) AS attempts,
  MAX(completed) AS completed,
  MAX(finished_at) AS last_attempt_at
FROM attempts
GROUP BY lesson_id
''');
    final map = <String, LessonProgress>{};
    for (final row in rows) {
      final id = row['lesson_id'] as String;
      map[id] = LessonProgress(
        lessonId: id,
        bestWpm: (row['best_wpm'] as num?)?.toDouble() ?? 0,
        bestAccuracy: (row['best_accuracy'] as num?)?.toDouble() ?? 0,
        bestStars: (row['best_stars'] as num?)?.toInt() ?? 0,
        attempts: (row['attempts'] as num?)?.toInt() ?? 0,
        completed: ((row['completed'] as num?)?.toInt() ?? 0) == 1,
        lastAttemptAt: row['last_attempt_at'] == null
            ? null
            : DateTime.tryParse(row['last_attempt_at'] as String),
      );
    }
    return map;
  }

  Future<UserStats> stats() async {
    final rows = await (await db).rawQuery('''
SELECT
  COALESCE(SUM(duration_ms), 0) AS total_ms,
  COALESCE(AVG(wpm), 0) AS avg_wpm,
  COALESCE(AVG(accuracy), 0) AS avg_accuracy,
  COUNT(*) AS attempts,
  COALESCE(SUM(stars), 0) AS stars
FROM attempts
''');
    final completedRows = await (await db).rawQuery(
      'SELECT COUNT(DISTINCT lesson_id) AS done FROM attempts WHERE completed = 1',
    );
    final row = rows.first;
    return UserStats(
      totalPracticeMs: (row['total_ms'] as num?)?.toInt() ?? 0,
      averageWpm: (row['avg_wpm'] as num?)?.toDouble() ?? 0,
      averageAccuracy: (row['avg_accuracy'] as num?)?.toDouble() ?? 0,
      completedLessons: (completedRows.first['done'] as num?)?.toInt() ?? 0,
      totalStars: (row['stars'] as num?)?.toInt() ?? 0,
      totalAttempts: (row['attempts'] as int?) ?? 0,
    );
  }

  Future<Set<String>> unlockedAchievements() async {
    final rows = await (await db).query('achievements');
    return rows.map((row) => row['id'] as String).toSet();
  }

  Future<void> unlockAchievement(String id) async {
    await (await db).insert(
      'achievements',
      {'id': id, 'unlocked_at': DateTime.now().toIso8601String()},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<File> backupFile() async {
    final dir = directoryOverride ?? await _defaultDirectory();
    await Directory(dir).create(recursive: true);
    return File(p.join(dir, AppConstants.backupFileName));
  }

  Future<File> exportBackup() async {
    final settings = await loadSettings();
    final attempts = await allAttempts();
    final achievements = (await unlockedAchievements()).toList();
    final payload = {
      'settings': settings.toMap(),
      'attempts': attempts.map((item) => item.toMap()).toList(),
      'achievements': achievements,
      'key_stats': (await keyStats()).map((item) => item.toMap()).toList(),
    };
    final file = await backupFile();
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(payload));
    return file;
  }

  Future<void> restoreBackup() async {
    final file = await backupFile();
    if (!await file.exists()) {
      throw StateError('Backup file not found');
    }
    final payload = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    final database = await db;
    await database.transaction((txn) async {
      await txn.delete('attempts');
      await txn.delete('achievements');
      await txn.delete('key_stats');
      await txn.delete('replays');
      final settings = AppSettings.fromMap(payload['settings'] as Map<String, dynamic>);
      await txn.update('settings', settings.toMap(), where: 'id = 1');
      for (final raw in payload['attempts'] as List<dynamic>) {
        final map = Map<String, dynamic>.from(raw as Map);
        map.remove('id');
        await txn.insert('attempts', map);
      }
      for (final raw in (payload['key_stats'] as List<dynamic>?) ?? const <dynamic>[]) {
        await txn.insert('key_stats', KeyStat.fromMap(Map<String, dynamic>.from(raw as Map)).toMap());
      }
      for (final id in payload['achievements'] as List<dynamic>) {
        await txn.insert('achievements', {
          'id': id,
          'unlocked_at': DateTime.now().toIso8601String(),
        });
      }
    });
  }

  Future<void> clearHistory() async {
    final database = await db;
    await database.transaction((txn) async {
      await txn.delete('attempts');
      await txn.delete('achievements');
      await txn.delete('key_stats');
      await txn.delete('replays');
      await txn.update('settings', {'last_lesson_id': null}, where: 'id = 1');
    });
  }

  static const String _replaysSql =
      'CREATE TABLE IF NOT EXISTS replays (attempt_id INTEGER PRIMARY KEY, data TEXT NOT NULL)';
  static const String _gameScoresSql =
      'CREATE TABLE IF NOT EXISTS game_scores (game TEXT PRIMARY KEY, best INTEGER NOT NULL)';

  /// Stores the key log of an attempt (only the newest 200 replays are kept).
  Future<void> saveReplay(int attemptId, String json) async {
    final database = await db;
    await database.insert('replays', {'attempt_id': attemptId, 'data': json}, conflictAlgorithm: ConflictAlgorithm.replace);
    await database.rawDelete(
      'DELETE FROM replays WHERE attempt_id NOT IN (SELECT attempt_id FROM replays ORDER BY attempt_id DESC LIMIT 200)',
    );
  }

  Future<String?> replayFor(int attemptId) async {
    final rows = await (await db).query('replays', where: 'attempt_id = ?', whereArgs: [attemptId], limit: 1);
    return rows.isEmpty ? null : rows.first['data'] as String;
  }

  Future<List<RecentAttempt>> recentAttempts({int limit = 12}) async {
    final rows = await (await db).rawQuery(
      'SELECT a.*, (r.attempt_id IS NOT NULL) AS has_replay FROM attempts a '
      'LEFT JOIN replays r ON r.attempt_id = a.id ORDER BY a.id DESC LIMIT ?',
      [limit],
    );
    return rows.map((row) {
      final map = Map<String, dynamic>.from(row);
      return RecentAttempt(LessonAttempt.fromMap(map), ((map['has_replay'] as num?)?.toInt() ?? 0) == 1);
    }).toList();
  }

  /// Practice time since local midnight, in milliseconds.
  Future<int> todayPracticeMs() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).toIso8601String();
    final rows = await (await db).rawQuery(
      'SELECT COALESCE(SUM(duration_ms), 0) AS total FROM attempts WHERE finished_at >= ?',
      [start],
    );
    return (rows.first['total'] as num).toInt();
  }

  /// Days (YYYY-MM-DD) with at least one attempt, newest first.
  Future<List<String>> practiceDays({int limit = 400}) async {
    final rows = await (await db).rawQuery(
      'SELECT DISTINCT substr(finished_at, 1, 10) AS day FROM attempts ORDER BY day DESC LIMIT ?',
      [limit],
    );
    return rows.map((row) => row['day'] as String).toList();
  }

  Future<Map<String, int>> gameScores() async {
    final rows = await (await db).query('game_scores');
    return {for (final row in rows) row['game'] as String: (row['best'] as num).toInt()};
  }

  Future<void> saveGameScore(String game, int score) async {
    final database = await db;
    await database.rawInsert('INSERT OR IGNORE INTO game_scores (game, best) VALUES (?, 0)', [game]);
    await database.rawUpdate('UPDATE game_scores SET best = ? WHERE game = ? AND best < ?', [score, game, score]);
  }

  static const String _keyStatsSql =
      'CREATE TABLE IF NOT EXISTS key_stats (char TEXT PRIMARY KEY, attempts INTEGER NOT NULL, errors INTEGER NOT NULL)';

  /// Adds one lesson's per-key counts to the lifetime totals.
  Future<void> recordKeyStats(Map<String, int> attempts, Map<String, int> errors) async {
    final database = await db;
    await database.transaction((txn) async {
      for (final entry in attempts.entries) {
        await txn.rawInsert('INSERT OR IGNORE INTO key_stats (char, attempts, errors) VALUES (?, 0, 0)', [entry.key]);
        await txn.rawUpdate(
          'UPDATE key_stats SET attempts = attempts + ?, errors = errors + ? WHERE char = ?',
          [entry.value, errors[entry.key] ?? 0, entry.key],
        );
      }
    });
  }

  Future<List<KeyStat>> keyStats() async {
    final rows = await (await db).query('key_stats');
    return rows.map((row) => KeyStat.fromMap(Map<String, dynamic>.from(row))).toList();
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
