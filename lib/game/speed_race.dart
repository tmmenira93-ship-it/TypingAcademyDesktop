/// "Speed Race": type a sentence before the ghost does. The ghost types at a steady
/// speed (by default the learner's own average). A wrong key does not move on.
class SpeedRace {
  SpeedRace({required this.text, required this.ghostWpm});

  final String text;
  final double ghostWpm;

  int typed = 0;
  int mistakes = 0;
  double elapsed = 0;
  bool started = false;

  double get ghostChars => elapsed * ghostWpm * 5 / 60;
  bool get playerFinished => typed >= text.length;
  bool get ghostFinished => ghostChars >= text.length;
  bool get isOver => playerFinished || ghostFinished;
  bool get won => playerFinished && !ghostFinished;

  int get score {
    final value = typed * 2 - mistakes * 5 + (won ? 100 : 0);
    return value < 0 ? 0 : value;
  }

  void update(double dt) {
    if (started && !isOver) {
      elapsed += dt;
    }
  }

  /// Returns true for a correct key.
  bool handleChar(String character) {
    if (isOver || character.isEmpty) {
      return false;
    }
    started = true;
    if (character == text[typed]) {
      typed += 1;
      return true;
    }
    mistakes += 1;
    return false;
  }
}
