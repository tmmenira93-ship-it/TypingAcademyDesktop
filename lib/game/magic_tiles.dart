import 'dart:math';

/// One falling tile. [y] is the top edge as a fraction of the playfield height
/// (0 = top, 1 = bottom); [note] is the melody note (0..7) it plays when hit.
class MagicTile {
  MagicTile(this.lane, this.y, this.note);

  final int lane;
  final int note;
  double y;
  bool hit = false;
}

/// "Magic Tiles": tiles fall in lanes, one lane per key. Press the lane's key when a tile
/// is low enough and the next note of the song plays. Missing a tile, or pressing a lane
/// that has no tile ready, costs a life. Pure Dart so it can be unit-tested.
class MagicTiles {
  MagicTiles({
    required this.laneKeys,
    required this.melody,
    Random? random,
    this.lives = 3,
  }) : _random = random ?? Random() {
    _addTile(0.5);
    _fill();
  }

  /// Tile height as a fraction of the playfield.
  static const double tileHeight = 0.24;

  /// Distance between the tops of consecutive tiles (the "beat").
  static const double spacing = 0.28;

  /// A tile can be hit once its bottom edge has passed this line.
  static const double reachableBottom = 0.55;

  /// A tile whose top passes this line is missed.
  static const double missTop = 0.88;

  /// Melodies as scale degrees 0..7 (C major: C D E F G A B C).
  static const List<List<int>> songs = [
    // Twinkle, twinkle, little star
    [0, 0, 4, 4, 5, 5, 4, 3, 3, 2, 2, 1, 1, 0, 4, 4, 3, 3, 2, 2, 1, 4, 4, 3, 3, 2, 2, 1, 0, 0, 4, 4, 5, 5, 4, 3, 3, 2, 2, 1, 1, 0],
    // Ode to Joy
    [2, 2, 3, 4, 4, 3, 2, 1, 0, 0, 1, 2, 2, 1, 1, 2, 2, 3, 4, 4, 3, 2, 1, 0, 0, 1, 2, 1, 0, 0],
    // Jingle Bells (chorus)
    [2, 2, 2, 2, 2, 2, 2, 4, 0, 1, 2, 3, 3, 3, 3, 3, 2, 2, 2, 2, 1, 1, 2, 1, 4],
  ];

  final List<String> laneKeys;
  final List<int> melody;
  final Random _random;

  int lives;
  int score = 0;
  int combo = 0;
  int bestCombo = 0;
  int hits = 0;
  int misses = 0;
  int level = 1;
  bool started = false;
  final List<MagicTile> tiles = <MagicTile>[];

  int _noteIndex = 0;
  int _lastLane = -1;
  int _sameLane = 0;

  bool get isOver => lives <= 0;

  /// Fall speed in playfield heights per second.
  double get speed => min(1.2, 0.34 + (level - 1) * 0.05);

  void update(double dt) {
    if (!started || isOver) {
      return;
    }
    final step = speed * dt;
    for (final tile in tiles) {
      tile.y += step;
    }
    for (final tile in List<MagicTile>.of(tiles)) {
      if (!tile.hit && tile.y >= missTop) {
        tiles.remove(tile);
        lives -= 1;
        misses += 1;
        combo = 0;
      } else if (tile.hit && tile.y >= 1.2) {
        tiles.remove(tile);
      }
    }
    _fill();
  }

  /// Press a lane. Returns the tile that was hit, or null for a miss.
  MagicTile? press(int lane) {
    if (isOver || lane < 0 || lane >= laneKeys.length) {
      return null;
    }
    MagicTile? target;
    for (final tile in tiles) {
      if (tile.lane == lane && !tile.hit && (target == null || tile.y > target.y)) {
        target = tile;
      }
    }
    if (target == null || target.y + tileHeight < reachableBottom) {
      if (started) {
        final anyReady = tiles.any((tile) => !tile.hit && tile.y + tileHeight >= reachableBottom);
        combo = 0;
        if (anyReady) {
          lives -= 1;
          misses += 1;
        }
      }
      return null;
    }
    target.hit = true;
    started = true;
    hits += 1;
    combo += 1;
    bestCombo = max(bestCombo, combo);
    final bottom = target.y + tileHeight;
    final quality = bottom >= 0.9 ? 3 : (bottom >= 0.75 ? 2 : 1);
    score += quality * 10 + min(combo, 20) * 2;
    if (hits % 10 == 0) {
      level += 1;
    }
    return target;
  }

  void _fill() {
    while (tiles.last.y - spacing >= -tileHeight) {
      _addTile(tiles.last.y - spacing);
    }
  }

  void _addTile(double y) {
    var lane = _random.nextInt(laneKeys.length);
    if (lane == _lastLane && _sameLane >= 2) {
      lane = (lane + 1 + _random.nextInt(laneKeys.length - 1)) % laneKeys.length;
    }
    if (lane == _lastLane) {
      _sameLane += 1;
    } else {
      _lastLane = lane;
      _sameLane = 1;
    }
    final note = melody.isEmpty ? 0 : melody[_noteIndex % melody.length];
    _noteIndex += 1;
    tiles.add(MagicTile(lane, y, note));
  }
}
