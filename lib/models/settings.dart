import 'package:flutter/material.dart';

class AppSettings {
  const AppSettings({
    this.languageCode = 'en',
    this.keyboardLayout = 'qwerty',
    this.themeMode = ThemeMode.system,
    this.fontScale = 1.0,
    this.lastLessonId,
    this.showKeyboard = true,
    this.showLiveStats = true,
    this.allowBackspace = true,
    this.blockOnError = false,
    this.showHands = true,
    this.keySounds = false,
    this.gameBest = 0,
    this.voiceOver = false,
  });

  final String languageCode;
  final String keyboardLayout;
  final ThemeMode themeMode;
  final double fontScale;
  final String? lastLessonId;

  /// Practice options (mirrors TypingClub's student settings).
  final bool showKeyboard;
  final bool showLiveStats;
  final bool allowBackspace;
  final bool blockOnError;
  final bool showHands;
  final bool keySounds;
  final int gameBest;
  final bool voiceOver;

  bool get isArabic => languageCode == 'ar';

  AppSettings copyWith({
    String? languageCode,
    String? keyboardLayout,
    ThemeMode? themeMode,
    double? fontScale,
    String? lastLessonId,
    bool clearLastLesson = false,
    bool? showKeyboard,
    bool? showLiveStats,
    bool? allowBackspace,
    bool? blockOnError,
    bool? showHands,
    bool? keySounds,
    int? gameBest,
    bool? voiceOver,
  }) {
    return AppSettings(
      languageCode: languageCode ?? this.languageCode,
      keyboardLayout: keyboardLayout ?? this.keyboardLayout,
      themeMode: themeMode ?? this.themeMode,
      fontScale: fontScale ?? this.fontScale,
      lastLessonId: clearLastLesson ? lastLessonId : (lastLessonId ?? this.lastLessonId),
      showKeyboard: showKeyboard ?? this.showKeyboard,
      showLiveStats: showLiveStats ?? this.showLiveStats,
      allowBackspace: allowBackspace ?? this.allowBackspace,
      blockOnError: blockOnError ?? this.blockOnError,
      showHands: showHands ?? this.showHands,
      keySounds: keySounds ?? this.keySounds,
      gameBest: gameBest ?? this.gameBest,
      voiceOver: voiceOver ?? this.voiceOver,
    );
  }

  Map<String, dynamic> toMap() => {
        'language_code': languageCode,
        'keyboard_layout': keyboardLayout,
        'theme_mode': themeMode.name,
        'font_scale': fontScale,
        'last_lesson_id': lastLessonId,
        'show_keyboard': showKeyboard ? 1 : 0,
        'show_live_stats': showLiveStats ? 1 : 0,
        'allow_backspace': allowBackspace ? 1 : 0,
        'block_on_error': blockOnError ? 1 : 0,
        'show_hands': showHands ? 1 : 0,
        'key_sounds': keySounds ? 1 : 0,
        'game_best': gameBest,
        'voice_over': voiceOver ? 1 : 0,
      };

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      languageCode: map['language_code'] as String? ?? 'en',
      keyboardLayout: map['keyboard_layout'] as String? ?? 'qwerty',
      themeMode: ThemeMode.values.firstWhere(
        (mode) => mode.name == map['theme_mode'],
        orElse: () => ThemeMode.system,
      ),
      fontScale: (map['font_scale'] as num?)?.toDouble() ?? 1.0,
      lastLessonId: map['last_lesson_id'] as String?,
      showKeyboard: ((map['show_keyboard'] as num?)?.toInt() ?? 1) == 1,
      showLiveStats: ((map['show_live_stats'] as num?)?.toInt() ?? 1) == 1,
      allowBackspace: ((map['allow_backspace'] as num?)?.toInt() ?? 1) == 1,
      blockOnError: ((map['block_on_error'] as num?)?.toInt() ?? 0) == 1,
      showHands: ((map['show_hands'] as num?)?.toInt() ?? 1) == 1,
      keySounds: ((map['key_sounds'] as num?)?.toInt() ?? 0) == 1,
      gameBest: (map['game_best'] as num?)?.toInt() ?? 0,
      voiceOver: ((map['voice_over'] as num?)?.toInt() ?? 0) == 1,
    );
  }
}
