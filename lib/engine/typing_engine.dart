enum CharStatus { pending, correct, incorrect, extra }

/// One key press, with the time since the first key (pauses excluded).
class KeyLogEntry {
  const KeyLogEntry(this.ms, this.key);

  static const String backspaceKey = '\b';

  final int ms;
  final String key;
}

/// Everything needed to play an attempt back.
class ReplayData {
  const ReplayData({
    required this.target,
    required this.log,
    required this.blockOnError,
    required this.allowBackspace,
  });

  final String target;
  final List<KeyLogEntry> log;
  final bool blockOnError;
  final bool allowBackspace;

  int get durationMs => log.isEmpty ? 0 : log.last.ms;

  Map<String, dynamic> toJson() => {
        't': target,
        'b': blockOnError,
        'a': allowBackspace,
        'l': [
          for (final entry in log) [entry.ms, entry.key],
        ],
      };

  factory ReplayData.fromJson(Map<String, dynamic> json) {
    return ReplayData(
      target: json['t'] as String,
      blockOnError: json['b'] as bool,
      allowBackspace: json['a'] as bool,
      log: [
        for (final raw in json['l'] as List<dynamic>)
          KeyLogEntry((raw as List<dynamic>)[0] as int, raw[1] as String),
      ],
    );
  }
}

class TypedChar {
  const TypedChar({required this.expected, required this.actual, required this.status});

  final String expected;
  final String? actual;
  final CharStatus status;
}

class TypingSnapshot {
  const TypingSnapshot({
    required this.target,
    required this.typed,
    required this.caretIndex,
    required this.chars,
    required this.correctCount,
    required this.errorCount,
    required this.startedAt,
    required this.elapsed,
    required this.paused,
    required this.finished,
  });

  final String target;
  final String typed;
  final int caretIndex;
  final List<TypedChar> chars;
  final int correctCount;
  final int errorCount;
  final DateTime? startedAt;
  final Duration elapsed;
  final bool paused;
  final bool finished;

  bool get hasStarted => startedAt != null;
}

class TypingResult {
  const TypingResult({
    required this.wpm,
    required this.accuracy,
    required this.errors,
    required this.duration,
    required this.stars,
    required this.completed,
    required this.correctChars,
    required this.totalChars,
  });

  final double wpm;
  final double accuracy;
  final int errors;
  final Duration duration;
  final int stars;
  final bool completed;
  final int correctChars;
  final int totalChars;
}

class TypingEngine {
  TypingEngine({
    required String target,
    this.goalWpm = 20,
    this.masteryAccuracy = 90,
    this.minWpm = 0,
    this.scored = true,
    this.blockOnError = false,
    this.allowBackspace = true,
    DateTime Function()? clock,
  })  : _target = target,
        _clock = clock ?? DateTime.now {
    reset();
  }

  final String _target;
  final int goalWpm;
  final double masteryAccuracy;
  final int minWpm;

  /// false for key-introduction lessons: no stars, finishing the text is enough.
  final bool scored;

  /// A wrong key is counted but not accepted; the learner must press the right key.
  /// Accuracy is then measured per key press (correct / all presses).
  final bool blockOnError;
  final bool allowBackspace;
  final DateTime Function() _clock;

  // Typed characters are stored one entry per key press, together with running
  // counters, so reading the live state never needs a full re-scan of the text.
  final List<String> _typedChars = <String>[];
  DateTime? _startedAt;
  DateTime? _pausedAt;
  Duration _pausedFor = Duration.zero;
  bool _paused = false;
  bool _finished = false;
  int _errorCount = 0;
  int _correct = 0;
  final Map<String, int> _keyAttempts = <String, int>{};
  final Map<String, int> _keyErrors = <String, int>{};
  final List<KeyLogEntry> _log = <KeyLogEntry>[];

  void reset() {
    _typedChars.clear();
    _startedAt = null;
    _pausedAt = null;
    _pausedFor = Duration.zero;
    _paused = false;
    _finished = false;
    _errorCount = 0;
    _correct = 0;
    _keyAttempts.clear();
    _keyErrors.clear();
    _log.clear();
  }

  // ---- cheap accessors used by the practice screen on every key press / tick
  String get target => _target;
  int get typedLength => _typedChars.length;
  int get correctCount => _correct;
  int get errorCount => _errorCount;
  bool get hasStarted => _startedAt != null;
  bool get isPaused => _paused;

  /// The key presses so far, for attempt playback.
  ReplayData replayData() => ReplayData(
        target: _target,
        log: List<KeyLogEntry>.unmodifiable(_log),
        blockOnError: blockOnError,
        allowBackspace: allowBackspace,
      );

  /// Per-key practice data (key = the expected character), used for weak-key stats.
  Map<String, int> get keyAttempts => Map<String, int>.unmodifiable(_keyAttempts);
  Map<String, int> get keyErrors => Map<String, int>.unmodifiable(_keyErrors);
  bool get isFinished => _finished || (_target.isNotEmpty && _typedChars.length >= _target.length);

  /// Status of the character at [index] of the target text.
  CharStatus statusAt(int index) {
    if (index >= _typedChars.length) {
      return CharStatus.pending;
    }
    return _typedChars[index] == _target[index] ? CharStatus.correct : CharStatus.incorrect;
  }

  /// Live speed while typing (correct characters / 5 per minute).
  double get liveWpm {
    final minutes = elapsed().inMilliseconds / 60000.0;
    return minutes <= 0 ? 0.0 : (_correct / 5.0) / minutes;
  }

  /// Live accuracy relative to what has been typed so far (100% before the first key).
  double get liveAccuracy {
    if (blockOnError) {
      final presses = _correct + _errorCount;
      return presses == 0 ? 100.0 : (_correct / presses) * 100.0;
    }
    return _typedChars.isEmpty ? 100.0 : (_correct / _typedChars.length) * 100.0;
  }

  /// Full snapshot. O(n): fine for tests and one-off reads, avoid in per-key UI code.
  TypingSnapshot snapshot() {
    final typed = _typedChars.join();
    return TypingSnapshot(
      target: _target,
      typed: typed,
      caretIndex: _typedChars.length.clamp(0, _target.length),
      chars: _buildChars(),
      correctCount: _correct,
      errorCount: _errorCount,
      startedAt: _startedAt,
      elapsed: elapsed(),
      paused: _paused,
      finished: isFinished,
    );
  }

  Duration elapsed() {
    if (_startedAt == null) {
      return Duration.zero;
    }
    final end = _paused ? (_pausedAt ?? _clock()) : _clock();
    final raw = end.difference(_startedAt!);
    final value = raw - _pausedFor;
    if (value.isNegative) {
      return Duration.zero;
    }
    return value;
  }

  void handleKey(String character) {
    if (_paused || _finished) {
      return;
    }
    if (character.isEmpty) {
      return;
    }
    _ensureStarted();
    if (_typedChars.length >= _target.length) {
      _finished = true;
      return;
    }
    _log.add(KeyLogEntry(elapsed().inMilliseconds, character));
    final expected = _target[_typedChars.length];
    _keyAttempts[expected] = (_keyAttempts[expected] ?? 0) + 1;
    if (character == expected) {
      _typedChars.add(character);
      _correct += 1;
    } else {
      _errorCount += 1;
      _keyErrors[expected] = (_keyErrors[expected] ?? 0) + 1;
      if (blockOnError) {
        return; // the wrong key is not accepted; the caret stays on the same character
      }
      _typedChars.add(character);
    }
    if (_typedChars.length >= _target.length) {
      _finished = true;
    }
  }

  void backspace() {
    if (!allowBackspace || blockOnError || _paused || _typedChars.isEmpty) {
      return;
    }
    _log.add(KeyLogEntry(elapsed().inMilliseconds, KeyLogEntry.backspaceKey));
    final removed = _typedChars.removeLast();
    final index = _typedChars.length;
    if (index < _target.length && removed == _target[index]) {
      _correct -= 1;
    }
    _finished = false;
  }

  void pause() {
    if (_paused || _startedAt == null || _finished) {
      return;
    }
    _paused = true;
    _pausedAt = _clock();
  }

  void resume() {
    if (!_paused) {
      return;
    }
    final now = _clock();
    if (_pausedAt != null) {
      _pausedFor += now.difference(_pausedAt!);
    }
    _paused = false;
    _pausedAt = null;
  }

  TypingResult result() {
    return computeResult(
      target: _target,
      typed: _typedChars.join(),
      duration: elapsed(),
      errors: _errorCount,
      goalWpm: goalWpm,
      masteryAccuracy: masteryAccuracy,
      minWpm: minWpm,
      scored: scored,
      keystrokeAccuracy: blockOnError,
    );
  }

  static TypingResult computeResult({
    required String target,
    required String typed,
    required Duration duration,
    required int errors,
    int goalWpm = 20,
    double masteryAccuracy = 90,
    int minWpm = 0,
    bool scored = true,
    bool keystrokeAccuracy = false,
  }) {
    final comparedLength = typed.length < target.length ? typed.length : target.length;
    var correct = 0;
    for (var i = 0; i < comparedLength; i++) {
      if (typed[i] == target[i]) {
        correct += 1;
      }
    }
    final total = target.isEmpty ? 0 : target.length;
    final minutes = duration.inMilliseconds <= 0 ? 0.0 : duration.inMilliseconds / 60000.0;
    final wpm = minutes <= 0 ? 0.0 : (correct / 5.0) / minutes;
    final double accuracy;
    if (keystrokeAccuracy) {
      final presses = correct + errors;
      accuracy = presses == 0 ? 0.0 : (correct / presses) * 100.0;
    } else {
      accuracy = total == 0 ? 0.0 : (correct / total) * 100.0;
    }
    final textFinished = total > 0 && typed.length >= total;
    final bool completed;
    final int stars;
    if (!scored) {
      // Key-introduction lessons: finishing the text is the only requirement.
      completed = textFinished;
      stars = 0;
    } else {
      completed = textFinished && accuracy >= masteryAccuracy && wpm >= minWpm;
      stars = starCount(
        wpm: wpm,
        accuracy: accuracy,
        goalWpm: goalWpm,
        masteryAccuracy: masteryAccuracy,
        minWpm: minWpm,
      );
    }
    return TypingResult(
      wpm: _round1(wpm),
      accuracy: _round1(accuracy),
      errors: errors,
      duration: duration,
      stars: stars,
      completed: completed,
      correctChars: correct,
      totalChars: total,
    );
  }

  /// 0 = requirements not met (below minimum accuracy or minimum speed).
  /// 1 = passed, 2 = halfway to the goal speed, 3 = goal speed reached,
  /// 4 = goal speed with 95%+ accuracy, 5 = 15% above goal with 98%+ accuracy.
  static int starCount({
    required double wpm,
    required double accuracy,
    required int goalWpm,
    required double masteryAccuracy,
    int minWpm = 0,
  }) {
    if (accuracy < masteryAccuracy || wpm < minWpm) {
      return 0;
    }
    var stars = 1;
    if (wpm >= minWpm + (goalWpm - minWpm) * 0.5) {
      stars = 2;
    }
    if (wpm >= goalWpm) {
      stars = 3;
    }
    if (wpm >= goalWpm && accuracy >= 95) {
      stars = 4;
    }
    if (wpm >= goalWpm * 1.15 && accuracy >= 98) {
      stars = 5;
    }
    return stars;
  }

  List<TypedChar> _buildChars() {
    final chars = <TypedChar>[];
    for (var i = 0; i < _target.length; i++) {
      final status = statusAt(i);
      chars.add(TypedChar(
        expected: _target[i],
        actual: i < _typedChars.length ? _typedChars[i] : null,
        status: status,
      ));
    }
    return chars;
  }

  void _ensureStarted() {
    _startedAt ??= _clock();
  }

  static double _round1(double value) => (value * 10).round() / 10;
}
