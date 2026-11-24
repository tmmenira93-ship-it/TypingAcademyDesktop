import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:typing_academy_desktop/core/constants.dart';
import 'package:typing_academy_desktop/data/database.dart';
import 'package:typing_academy_desktop/data/lesson_catalog.dart';
import 'package:typing_academy_desktop/engine/typing_engine.dart';
import 'package:typing_academy_desktop/models/attempt.dart';
import 'package:typing_academy_desktop/models/settings.dart';
import 'package:typing_academy_desktop/state/app_state.dart';

void main() {
  late Directory tempDir;
  late AppDatabase database;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('typing_academy_');
    database = AppDatabase(directoryOverride: tempDir.path);
  });

  tearDown(() async {
    await database.close();
  });

  test('saves and reloads attempts after restart', () async {
    final attempt = LessonAttempt(
      lessonId: 'home-row-intro',
      startedAt: DateTime(2026, 1, 1, 12),
      finishedAt: DateTime(2026, 1, 1, 12, 1),
      durationMs: 60000,
      wpm: 21,
      accuracy: 96,
      errors: 1,
      stars: 2,
      completed: true,
    );
    await database.insertAttempt(attempt);
    await database.close();

    final reopened = AppDatabase(directoryOverride: tempDir.path);
    final loaded = await reopened.attemptsFor('home-row-intro');
    expect(loaded, isNotEmpty);
    expect(loaded.first.wpm, 21);
    expect(loaded.first.completed, isTrue);
    final progress = await reopened.progressFor('home-row-intro');
    expect(progress?.completed, isTrue);
    await reopened.close();
  });

  test('app state unlocks the next lesson after mastery', () async {
    final state = AppState(database: database);
    await state.load();
    final first = LessonCatalog.all.first;
    expect(state.isUnlocked(LessonCatalog.all[1]), isFalse);
    final result = TypingEngine.computeResult(
      target: first.targetText,
      typed: first.targetText,
      duration: const Duration(seconds: 20),
      errors: 0,
      goalWpm: first.goalWpm,
      masteryAccuracy: first.masteryAccuracy,
    );
    await state.saveResult(
      lesson: first,
      result: result,
      startedAt: DateTime(2026, 1, 1),
      finishedAt: DateTime(2026, 1, 1, 0, 0, 20),
    );
    expect(state.isUnlocked(LessonCatalog.all[1]), isTrue);
    expect(state.progress[first.id]?.completed, isTrue);
  });

  test('backup restore and history delete work locally', () async {
    final state = AppState(database: database);
    await state.load();
    final first = LessonCatalog.all.first;
    final result = TypingEngine.computeResult(
      target: first.targetText,
      typed: first.targetText,
      duration: const Duration(seconds: 20),
      errors: 0,
      goalWpm: first.goalWpm,
      masteryAccuracy: first.masteryAccuracy,
    );
    await state.saveResult(
      lesson: first,
      result: result,
      startedAt: DateTime(2026, 1, 1),
      finishedAt: DateTime(2026, 1, 1, 0, 0, 20),
    );
    await state.backup();
    await state.deleteHistory();
    expect(state.stats.totalAttempts, 0);
    await state.restore();
    expect(state.stats.totalAttempts, 1);
  });

  test('language setting persists', () async {
    final state = AppState(database: database);
    await state.load();
    await state.setLanguage('ar', 'arabic');
    await database.close();
    final next = AppDatabase(directoryOverride: tempDir.path);
    final settings = await next.loadSettings();
    expect(settings.languageCode, 'ar');
    expect(settings.keyboardLayout, 'arabic');
    await next.close();
  });

  test('practice options persist and default to on for older data', () async {
    final state = AppState(database: database);
    await state.load();
    expect(state.settings.showKeyboard, isTrue);
    await state.setPracticeOptions(showKeyboard: false, allowBackspace: false);
    await database.close();
    final next = AppDatabase(directoryOverride: tempDir.path);
    final settings = await next.loadSettings();
    expect(settings.showKeyboard, isFalse);
    expect(settings.showLiveStats, isTrue);
    expect(settings.allowBackspace, isFalse);
    await next.close();
    expect(AppSettings.fromMap(<String, dynamic>{'language_code': 'en'}).showKeyboard, isTrue);
  });

  test('upgrades a version 1 database without losing settings', () async {
    final path = p.join(tempDir.path, AppConstants.dbFileName);
    final old = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute(
            'CREATE TABLE settings (id INTEGER PRIMARY KEY CHECK (id = 1), language_code TEXT NOT NULL, '
            'keyboard_layout TEXT NOT NULL, theme_mode TEXT NOT NULL, font_scale REAL NOT NULL, last_lesson_id TEXT)',
          );
          await db.insert('settings', {
            'id': 1,
            'language_code': 'ar',
            'keyboard_layout': 'arabic',
            'theme_mode': 'dark',
            'font_scale': 1.2,
            'last_lesson_id': null,
          });
        },
      ),
    );
    await old.close();
    final upgraded = AppDatabase(directoryOverride: tempDir.path);
    final settings = await upgraded.loadSettings();
    expect(settings.languageCode, 'ar');
    expect(settings.themeMode, ThemeMode.dark);
    expect(settings.showKeyboard, isTrue);
    await upgraded.close();
  });

  test('key stats accumulate per key and weak keys are found', () async {
    await database.recordKeyStats({'a': 10, 'q': 10}, {'q': 4});
    await database.recordKeyStats({'q': 5}, {'q': 1});
    final stats = await database.keyStats();
    final q = stats.firstWhere((item) => item.char == 'q');
    expect(q.attempts, 15);
    expect(q.errors, 5);
    final state = AppState(database: database);
    await state.load();
    expect(state.weakKeys.map((item) => item.char).toList(), ['q']);
    await state.deleteHistory();
    expect(await database.keyStats(), isEmpty);
  });

  test('game best score persists and a lower score is ignored', () async {
    final state = AppState(database: database);
    await state.load();
    await state.saveGameBest(120);
    await state.saveGameBest(80);
    expect(state.settings.gameBest, 120);
    await database.close();
    final next = AppDatabase(directoryOverride: tempDir.path);
    final settings = await next.loadSettings();
    expect(settings.gameBest, 120);
    expect(settings.showHands, isTrue);
    expect(settings.keySounds, isFalse);
    await next.close();
  });

  test('replays and game scores are stored', () async {
    final attempt = LessonAttempt(
      lessonId: 'x',
      startedAt: DateTime(2026),
      finishedAt: DateTime(2026),
      durationMs: 1000,
      wpm: 20,
      accuracy: 100,
      errors: 0,
      stars: 3,
      completed: true,
    );
    final id = await database.insertAttempt(attempt);
    await database.saveReplay(id, '{"t":"ab","b":false,"a":true,"l":[[0,"a"],[300,"b"]]}');
    final recent = await database.recentAttempts();
    expect(recent.first.hasReplay, isTrue);
    final data = ReplayData.fromJson(jsonDecode((await database.replayFor(id))!) as Map<String, dynamic>);
    expect(data.log.length, 2);
    await database.saveGameScore('word-sprint', 50);
    await database.saveGameScore('word-sprint', 30);
    expect((await database.gameScores())['word-sprint'], 50);
  });
}
