import 'dart:math';

class FallingWord {
  FallingWord(this.text, this.x);

  final String text;

  /// Horizontal position, 0..1 of the playfield width.
  final double x;

  /// Vertical position, 0 (top) .. 1 (ground).
  double y = 0;

  /// Letters already typed correctly.
  int typed = 0;
}

/// Game logic for "Word Rain": words fall, the player types them to clear them.
/// Pure Dart (no Flutter) so it can be unit-tested.
class WordRainGame {
  WordRainGame({required List<String> words, Random? random, this.lives = 3, this.speed = 1.0})
      : _words = words.isEmpty ? const ['fall', 'jade', 'sad'] : words,
        _random = random ?? Random();

  final List<String> _words;
  final Random _random;

  /// Overall pace multiplier (Letter Pop is a little faster than Word Rain).
  final double speed;

  int lives;
  int score = 0;
  int level = 1;
  int cleared = 0;
  int streak = 0;
  final List<FallingWord> active = <FallingWord>[];
  FallingWord? target;
  double _spawnIn = 0.4;

  bool get isOver => lives <= 0;

  void update(double dt) {
    if (isOver) {
      return;
    }
    _spawnIn -= dt;
    if (_spawnIn <= 0) {
      _spawn();
      _spawnIn = max(1.0, 3.0 - level * 0.2) / speed;
    }
    final fall = (0.09 + level * 0.014) * speed;
    for (final word in List<FallingWord>.of(active)) {
      word.y += fall * dt;
      if (word.y >= 1.0) {
        active.remove(word);
        if (identical(word, target)) {
          target = null;
        }
        lives -= 1;
        streak = 0;
      }
    }
  }

  /// Handle one typed character. Returns true when it was a correct letter.
  bool handleChar(String character) {
    if (isOver || character.isEmpty) {
      return false;
    }
    final ch = character.toLowerCase();
    var current = target;
    if (current == null) {
      FallingWord? best;
      for (final word in active) {
        if (word.text.startsWith(ch) && (best == null || word.y > best.y)) {
          best = word;
        }
      }
      if (best == null) {
        streak = 0;
        return false;
      }
      current = best;
      target = best;
    }
    if (current.text[current.typed] != ch) {
      streak = 0;
      return false;
    }
    current.typed += 1;
    if (current.typed >= current.text.length) {
      streak += 1;
      score += current.text.length * 10 + min(streak, 10) * 5;
      active.remove(current);
      target = null;
      cleared += 1;
      if (cleared % 8 == 0) {
        level += 1;
      }
    }
    return true;
  }

  void _spawn() {
    String? text;
    for (var attempt = 0; attempt < 12; attempt++) {
      final candidate = _words[_random.nextInt(_words.length)];
      final clash = active.any((word) => word.text[0] == candidate[0]);
      if (!clash) {
        text = candidate;
        break;
      }
    }
    if (text == null) {
      return;
    }
    active.add(FallingWord(text, 0.04 + _random.nextDouble() * 0.7));
  }
}
