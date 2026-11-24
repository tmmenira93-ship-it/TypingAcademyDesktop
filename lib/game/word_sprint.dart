import 'dart:math';

/// "Word Sprint": type as many words as possible before the clock runs out.
/// The clock starts with the first key. A wrong key does not move on.
class WordSprint {
  WordSprint({required List<String> words, Random? random, this.durationSeconds = 60})
      : _words = words.isEmpty ? const ['fall', 'jade', 'sad'] : words,
        _random = random ?? Random(),
        remaining = durationSeconds.toDouble() {
    current = _pick('');
  }

  final List<String> _words;
  final Random _random;
  final int durationSeconds;

  double remaining;
  bool started = false;
  int completed = 0;
  int mistakes = 0;
  int correctKeys = 0;
  int position = 0;
  late String current;

  bool get isOver => started && remaining <= 0;

  int get score => max(0, correctKeys * 5 + completed * 10 - mistakes * 3);

  void update(double dt) {
    if (!started || isOver) {
      return;
    }
    remaining = max(0.0, remaining - dt);
  }

  /// Returns true for a correct key.
  bool handleChar(String character) {
    if (isOver || character.isEmpty) {
      return false;
    }
    started = true;
    final ch = character.toLowerCase();
    if (current[position] == ch) {
      position += 1;
      correctKeys += 1;
      if (position >= current.length) {
        completed += 1;
        position = 0;
        current = _pick(current);
      }
      return true;
    }
    mistakes += 1;
    return false;
  }

  String _pick(String previous) {
    for (var i = 0; i < 8; i++) {
      final candidate = _words[_random.nextInt(_words.length)];
      if (candidate != previous) {
        return candidate;
      }
    }
    return _words.first;
  }
}
