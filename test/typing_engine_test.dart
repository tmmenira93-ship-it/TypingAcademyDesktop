import 'package:flutter_test/flutter_test.dart';
import 'package:typing_academy_desktop/engine/typing_engine.dart';

void main() {
  test('empty target yields zero scores', () {
    final result = TypingEngine.computeResult(
      target: '',
      typed: '',
      duration: const Duration(seconds: 10),
      errors: 0,
    );
    expect(result.wpm, 0);
    expect(result.accuracy, 0);
    expect(result.completed, isFalse);
  });

  test('perfect typing calculates wpm and accuracy', () {
    final result = TypingEngine.computeResult(
      target: 'hello world test',
      typed: 'hello world test',
      duration: const Duration(seconds: 60),
      errors: 0,
      goalWpm: 10,
      masteryAccuracy: 90,
    );
    expect(result.accuracy, 100);
    expect(result.correctChars, 16);
    expect(result.wpm, closeTo(3.2, 0.1));
    expect(result.completed, isTrue);
    expect(result.stars, greaterThanOrEqualTo(1));
  });

  test('errors reduce accuracy and are counted', () {
    final engine = TypingEngine(
      target: 'cat',
      clock: () => DateTime(2026, 1, 1, 12, 0, 5),
    );
    engine.handleKey('c');
    engine.handleKey('x');
    engine.handleKey('t');
    final result = engine.result();
    expect(result.errors, 1);
    expect(result.accuracy, closeTo(66.7, 0.1));
    expect(result.completed, isFalse);
  });

  test('backspace can correct a mistake', () {
    final engine = TypingEngine(target: 'ab');
    engine.handleKey('a');
    engine.handleKey('x');
    engine.backspace();
    engine.handleKey('b');
    final snap = engine.snapshot();
    expect(snap.typed, 'ab');
    expect(snap.errorCount, 1);
    expect(engine.result().accuracy, 100);
    expect(engine.result().completed, isTrue);
  });

  test('pause freezes elapsed time', () {
    var now = DateTime(2026, 1, 1, 12);
    final engine = TypingEngine(target: 'aa', clock: () => now);
    engine.handleKey('a');
    now = now.add(const Duration(seconds: 10));
    engine.pause();
    now = now.add(const Duration(seconds: 30));
    engine.resume();
    expect(engine.elapsed().inSeconds, 10);
  });

  test('unexpected empty key is ignored', () {
    final engine = TypingEngine(target: 'a');
    engine.handleKey('');
    expect(engine.snapshot().typed, isEmpty);
  });

  test('live counters stay in sync with typing and backspace', () {
    final engine = TypingEngine(target: 'abc');
    expect(engine.liveAccuracy, 100);
    engine.handleKey('a');
    engine.handleKey('x');
    expect(engine.typedLength, 2);
    expect(engine.correctCount, 1);
    expect(engine.errorCount, 1);
    expect(engine.liveAccuracy, closeTo(50, 0.01));
    expect(engine.statusAt(0), CharStatus.correct);
    expect(engine.statusAt(1), CharStatus.incorrect);
    expect(engine.statusAt(2), CharStatus.pending);
    engine.backspace();
    expect(engine.typedLength, 1);
    expect(engine.correctCount, 1);
    engine.backspace();
    expect(engine.correctCount, 0);
    expect(engine.isFinished, isFalse);
  });

  test('engine reports finished once the whole target is typed', () {
    final engine = TypingEngine(target: 'ab');
    engine.handleKey('a');
    expect(engine.isFinished, isFalse);
    engine.handleKey('b');
    expect(engine.isFinished, isTrue);
    engine.reset();
    expect(engine.isFinished, isFalse);
    expect(engine.correctCount, 0);
  });

  test('block on error keeps the caret until the right key is pressed', () {
    final engine = TypingEngine(target: 'ab', blockOnError: true);
    engine.handleKey('x');
    expect(engine.typedLength, 0);
    expect(engine.errorCount, 1);
    expect(engine.liveAccuracy, 0);
    engine.handleKey('a');
    engine.backspace();
    expect(engine.typedLength, 1);
    engine.handleKey('b');
    expect(engine.isFinished, isTrue);
    final result = engine.result();
    expect(result.accuracy, closeTo(66.7, 0.1));
    expect(engine.keyAttempts['a'], 2);
    expect(engine.keyErrors['a'], 1);
  });

  test('intro lessons are score-free and finishing the text completes them', () {
    final result = TypingEngine.computeResult(
      target: 'ff jj',
      typed: 'ff jj',
      duration: const Duration(seconds: 10),
      errors: 3,
      scored: false,
      keystrokeAccuracy: true,
    );
    expect(result.completed, isTrue);
    expect(result.stars, 0);
  });

  test('five-star scale with a minimum speed gate', () {
    int stars(double wpm, double accuracy) {
      return TypingEngine.starCount(
        wpm: wpm,
        accuracy: accuracy,
        goalWpm: 20,
        masteryAccuracy: 90,
        minWpm: 10,
      );
    }

    expect(stars(9, 100), 0);
    expect(stars(15, 89), 0);
    expect(stars(10, 90), 1);
    expect(stars(15, 90), 2);
    expect(stars(20, 90), 3);
    expect(stars(20, 95), 4);
    expect(stars(23, 98), 5);
  });

  test('key log records every key press for playback', () {
    final engine = TypingEngine(target: 'ab');
    engine.handleKey('a');
    engine.handleKey('x');
    engine.backspace();
    engine.handleKey('b');
    final data = engine.replayData();
    expect(data.target, 'ab');
    expect(data.log.map((entry) => entry.key).toList(), ['a', 'x', KeyLogEntry.backspaceKey, 'b']);
    expect(data.log.first.ms, lessThan(50));
  });

  test('replay data survives a JSON round trip', () {
    final engine = TypingEngine(target: 'ab');
    engine.handleKey('a');
    engine.handleKey('b');
    final data = engine.replayData();
    final copy = ReplayData.fromJson(data.toJson());
    expect(copy.target, 'ab');
    expect(copy.log.map((entry) => entry.key).toList(), ['a', 'b']);
    expect(copy.blockOnError, isFalse);
  });
}
