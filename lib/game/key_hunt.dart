import 'dart:math';

/// "Key Hunt": a key appears, find it on the keyboard and press it. After a short
/// moment the key is highlighted on the on-screen keyboard as a hint (fewer points).
/// A key that is not found in time counts as a miss.
class KeyHunt {
  KeyHunt({
    required List<String> keys,
    Random? random,
    this.durationSeconds = 45,
    this.perKeySeconds = 3.0,
    this.hintAfterSeconds = 1.5,
  })  : _keys = keys.isEmpty ? const ['f', 'j'] : keys,
        _random = random ?? Random(),
        remaining = durationSeconds.toDouble(),
        keyTimeLeft = perKeySeconds {
    current = _pick('');
  }

  final List<String> _keys;
  final Random _random;
  final int durationSeconds;
  final double perKeySeconds;
  final double hintAfterSeconds;

  double remaining;
  double keyTimeLeft;
  bool started = false;
  int hits = 0;
  int misses = 0;
  int streak = 0;
  int bestStreak = 0;
  int score = 0;
  late String current;

  bool get isOver => started && remaining <= 0;

  /// The highlight on the on-screen keyboard shows once the hint delay has passed.
  bool get hinted => perKeySeconds - keyTimeLeft >= hintAfterSeconds;

  void update(double dt) {
    if (!started || isOver) {
      return;
    }
    remaining = max(0.0, remaining - dt);
    keyTimeLeft -= dt;
    if (keyTimeLeft <= 0 && !isOver) {
      _miss();
      current = _pick(current);
      keyTimeLeft = perKeySeconds;
    }
  }

  /// Returns true when the right key was pressed.
  bool handleChar(String character) {
    if (isOver || character.isEmpty) {
      return false;
    }
    started = true;
    final pressed = character.toLowerCase();
    if (pressed == current) {
      hits += 1;
      streak += 1;
      bestStreak = max(bestStreak, streak);
      score += (hinted ? 5 : 10) + min(streak, 10) * 2;
      current = _pick(current);
      keyTimeLeft = perKeySeconds;
      return true;
    }
    _miss();
    return false;
  }

  void _miss() {
    misses += 1;
    streak = 0;
    score = max(0, score - 5);
  }

  String _pick(String previous) {
    for (var i = 0; i < 8; i++) {
      final candidate = _keys[_random.nextInt(_keys.length)];
      if (candidate != previous) {
        return candidate;
      }
    }
    return _keys.first;
  }
}
