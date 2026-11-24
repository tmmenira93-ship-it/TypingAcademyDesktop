import 'dart:convert';

import 'package:flutter/material.dart';

import '../core/l10n.dart';
import '../data/achievements_catalog.dart';
import '../data/curriculum.dart';
import '../data/database.dart';
import '../data/lesson_catalog.dart';
import '../engine/typing_engine.dart';
import '../models/attempt.dart';
import '../models/key_stat.dart';
import '../models/lesson.dart';
import '../models/settings.dart';
import '../services/sound_service.dart';
import '../services/speech_service.dart';

class AppState extends ChangeNotifier {
  AppState({AppDatabase? database}) : _database = database ?? AppDatabase();

  final AppDatabase _database;

  AppSettings settings = const AppSettings();
  List<KeyStat> keyStats = const [];

  static const String dynamicLessonId = 'dynamic-practice';

  final SoundService sounds = SoundService();
  final SpeechService speech = SpeechService();
  List<RecentAttempt> recent = const [];
  int todayMs = 0;
  int streakDays = 0;

  /// Daily practice goal shown on the home screen.
  static const int dailyGoalMinutes = 10;
  Map<String, int> gameScores = const {};
  Map<String, LessonProgress> progress = {};
  UserStats stats = const UserStats(
    totalPracticeMs: 0,
    averageWpm: 0,
    averageAccuracy: 0,
    completedLessons: 0,
    totalStars: 0,
    totalAttempts: 0,
  );
  List<Achievement> achievements = const [];
  bool ready = false;
  String? statusMessage;

  S get l10n => S(settings.languageCode);
  bool get isArabic => settings.isArabic;
  List<Lesson> get lessons => LessonCatalog.all;
  late final List<LessonStage> stages = LessonCatalog.stages();

  Future<void> load() async {
    achievements = const [];
    settings = await _database.loadSettings();
    await refreshProgress();
    ready = true;
    notifyListeners();
  }

  Future<void> refreshProgress() async {
    final progressFuture = _database.allProgress();
    final statsFuture = _database.stats();
    progress = await progressFuture;
    stats = await statsFuture;
    keyStats = await _database.keyStats();
    recent = await _database.recentAttempts(limit: 30);
    todayMs = await _database.todayPracticeMs();
    streakDays = streakFrom(await _database.practiceDays(), DateTime.now());
    gameScores = await _database.gameScores();
    final bestWpm = progress.values.fold<double>(0, (max, item) => item.bestWpm > max ? item.bestWpm : max);
    final alreadyUnlocked = {
      for (final item in achievements)
        if (item.unlocked) item.id,
    };
    achievements = AchievementsCatalog.evaluate(
      completedLessons: stats.completedLessons,
      totalStars: stats.totalStars,
      averageAccuracy: stats.averageAccuracy,
      bestWpm: bestWpm,
      totalAttempts: stats.totalAttempts,
      totalLessons: lessons.length,
      fiveStarLessons: progress.values.where((item) => item.bestStars >= 5).length,
      practiceMinutes: stats.totalPracticeMs / 60000.0,
      gameBest: settings.gameBest,
      gamesPlayed: (settings.gameBest > 0 ? 1 : 0) + gameScores.values.where((value) => value > 0).length,
    );
    // Persist only achievements that are new since the last refresh.
    for (final item in achievements) {
      if (item.unlocked && !alreadyUnlocked.contains(item.id)) {
        await _database.unlockAchievement(item.id);
      }
    }
  }

  Future<void> updateSettings(AppSettings next) async {
    settings = next;
    await _database.saveSettings(next);
    notifyListeners();
  }

  Future<void> setLanguage(String code, String layout) {
    return updateSettings(settings.copyWith(languageCode: code, keyboardLayout: layout));
  }

  Future<void> setTheme(ThemeMode mode) {
    return updateSettings(settings.copyWith(themeMode: mode));
  }

  Future<void> setFontScale(double scale) {
    return updateSettings(settings.copyWith(fontScale: scale));
  }

  Future<void> setPracticeOptions({
    bool? showKeyboard,
    bool? showLiveStats,
    bool? allowBackspace,
    bool? blockOnError,
    bool? showHands,
    bool? keySounds,
    bool? voiceOver,
  }) {
    return updateSettings(settings.copyWith(
      showKeyboard: showKeyboard,
      showLiveStats: showLiveStats,
      allowBackspace: allowBackspace,
      blockOnError: blockOnError,
      showHands: showHands,
      keySounds: keySounds,
      voiceOver: voiceOver,
    ));
  }

  Future<void> saveGameBest(int score) async {
    if (score <= settings.gameBest) {
      return;
    }
    await updateSettings(settings.copyWith(gameBest: score));
    await refreshProgress();
    notifyListeners();
  }

  Future<ReplayData?> replayFor(int attemptId) async {
    final json = await _database.replayFor(attemptId);
    if (json == null) {
      return null;
    }
    try {
      return ReplayData.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Best score of a game. Word Rain keeps its score in the settings, the others in game_scores.
  int bestFor(String gameId) => gameId == 'word-rain' ? settings.gameBest : (gameScores[gameId] ?? 0);

  Future<void> saveGameScore(String gameId, int score) async {
    if (score <= (gameScores[gameId] ?? 0)) {
      return;
    }
    await _database.saveGameScore(gameId, score);
    await refreshProgress();
    notifyListeners();
  }

  List<String> huntKeys() {
    return Curriculum.huntKeys(<String>{for (final item in keyStats) item.char});
  }

  List<String> gameLetters() {
    return Curriculum.gameLetters(<String>{for (final item in keyStats) item.char});
  }

  /// Words for the Word Rain game, limited to keys the learner has practised.
  List<String> gameWords() {
    return Curriculum.gameWords(<String>{for (final item in keyStats) item.char});
  }

  bool isUnlocked(Lesson lesson) {
    if (lesson.unlockAfterId == null) {
      return true;
    }
    return progress[lesson.unlockAfterId!]?.completed == true;
  }

  Lesson? get lastLesson {
    final id = settings.lastLessonId;
    if (id == null) {
      return lessons.first;
    }
    return LessonCatalog.byId(id) ?? lessons.first;
  }

  Lesson? get continueLesson {
    for (final lesson in lessons) {
      if (isUnlocked(lesson) && progress[lesson.id]?.completed != true) {
        return lesson;
      }
    }
    return lessons.last;
  }

  /// Consecutive practice days ending today (or yesterday, so the streak is not lost
  /// before the learner has had a chance to practise today).
  static int streakFrom(List<String> days, DateTime now) {
    if (days.isEmpty) {
      return 0;
    }
    String fmt(DateTime day) =>
        '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    final set = days.toSet();
    var cursor = DateTime(now.year, now.month, now.day);
    if (!set.contains(fmt(cursor))) {
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
      if (!set.contains(fmt(cursor))) {
        return 0;
      }
    }
    var streak = 0;
    while (set.contains(fmt(cursor))) {
      streak += 1;
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    }
    return streak;
  }

  String learnerLevel() {
    final done = stats.completedLessons;
    final total = lessons.length;
    if (done >= total * 0.9) {
      return l10n.expert;
    }
    if (done >= total * 0.5) {
      return l10n.typist;
    }
    if (done >= total * 0.15) {
      return l10n.learner;
    }
    return l10n.beginner;
  }

  /// Keys the learner misses most (needs some practice data first), worst first.
  List<KeyStat> get weakKeys {
    final candidates = keyStats
        .where((item) => item.char.trim().isNotEmpty && item.attempts >= 8 && item.errorRate >= 0.08)
        .toList()
      ..sort((a, b) {
        final byRate = b.errorRate.compareTo(a.errorRate);
        return byRate != 0 ? byRate : b.attempts.compareTo(a.attempts);
      });
    return candidates.take(5).toList();
  }

  /// A fresh practice lesson built from the weak keys (TypingClub's "dynamic" lesson), or null.
  Lesson? dynamicLesson() {
    final weak = weakKeys;
    if (weak.isEmpty) {
      return null;
    }
    final chars = weak.map((item) => item.char).toList();
    final known = <String>{for (final item in keyStats) item.char};
    final goal = stats.averageWpm.round().clamp(10, 60).toInt();
    final shown = chars.join(' ');
    return Lesson(
      id: dynamicLessonId,
      stageId: 'weak-keys',
      stageTitleEn: 'Weak keys',
      stageTitleAr: 'المفاتيح الضعيفة',
      order: 0,
      titleEn: 'Weak keys practice',
      titleAr: 'تدريب المفاتيح الضعيفة',
      instructionsEn: 'Practice built from the keys you miss most ($shown). Slow down and aim for accuracy.',
      instructionsAr: 'تدريب مبني على المفاتيح التي تخطئ فيها أكثر ($shown). أبطئ وركّز على الدقة.',
      targetText: Curriculum.dynamicText(chars, known),
      goalWpm: goal,
      masteryAccuracy: 90,
      type: LessonType.weakKeys,
    );
  }

  Future<LessonAttempt> saveResult({
    required Lesson lesson,
    required TypingResult result,
    required DateTime startedAt,
    required DateTime finishedAt,
    Map<String, int> keyAttempts = const <String, int>{},
    Map<String, int> keyErrors = const <String, int>{},
    ReplayData? replay,
  }) async {
    final isWeakKeys = lesson.type == LessonType.weakKeys;
    final attempt = LessonAttempt(
      lessonId: lesson.id,
      startedAt: startedAt,
      finishedAt: finishedAt,
      durationMs: result.duration.inMilliseconds,
      wpm: result.wpm,
      accuracy: result.accuracy,
      errors: result.errors,
      stars: result.stars,
      // Weak-key practice never counts as a completed course lesson.
      completed: isWeakKeys ? false : result.completed,
    );
    final attemptId = await _database.insertAttempt(attempt);
    if (replay != null) {
      await _database.saveReplay(attemptId, jsonEncode(replay.toJson()));
    }
    if (keyAttempts.isNotEmpty) {
      await _database.recordKeyStats(keyAttempts, keyErrors);
    }
    if (!isWeakKeys && settings.lastLessonId != lesson.id) {
      final next = settings.copyWith(lastLessonId: lesson.id);
      await _database.saveSettings(next);
      settings = next;
    }
    await refreshProgress();
    notifyListeners();
    return attempt;
  }

  Future<List<LessonAttempt>> historyFor(String lessonId) {
    return _database.attemptsFor(lessonId);
  }

  Future<void> backup() async {
    await _database.exportBackup();
    statusMessage = l10n.backupDone;
    notifyListeners();
  }

  Future<void> restore() async {
    await _database.restoreBackup();
    await load();
    statusMessage = l10n.restoreDone;
    notifyListeners();
  }

  Future<void> deleteHistory() async {
    await _database.clearHistory();
    await load();
    statusMessage = l10n.historyDeleted;
    notifyListeners();
  }

  List<Lesson> reviewLessons() {
    return lessons.where((lesson) {
      final item = progress[lesson.id];
      if (item == null || !lesson.isScored) {
        return false;
      }
      return item.attempts > 0 && (!item.completed || item.bestAccuracy < 92);
    }).toList();
  }
}
