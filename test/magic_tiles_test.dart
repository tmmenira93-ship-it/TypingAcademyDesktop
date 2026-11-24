import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:typing_academy_desktop/game/magic_tiles.dart';

MagicTiles newGame() {
  return MagicTiles(laneKeys: ['d', 'f', 'j', 'k'], melody: [0, 1, 2], random: Random(1));
}

void main() {
  test('tiles start spaced out and follow the melody', () {
    final game = newGame();
    expect(game.tiles.map((tile) => tile.note).toList(), [0, 1, 2]);
    expect(game.started, isFalse);
  });

  test('hitting the lowest tile starts the game and scores', () {
    final game = newGame();
    final first = game.tiles.first;
    final hit = game.press(first.lane);
    expect(hit, same(first));
    expect(game.started, isTrue);
    expect(game.combo, 1);
    expect(game.score, greaterThan(0));
  });

  test('before the game starts a wrong lane costs nothing', () {
    final game = newGame();
    final wrong = (game.tiles.first.lane + 1) % 4;
    expect(game.press(wrong), isNull);
    expect(game.lives, 3);
    expect(game.started, isFalse);
  });

  test('pressing a lane with no tile ready while another is ready costs a life', () {
    final game = newGame();
    game.press(game.tiles.first.lane);
    game.update(0.3);
    final ready = game.tiles.where((t) => !t.hit && t.y + MagicTiles.tileHeight >= MagicTiles.reachableBottom).toList();
    expect(ready, isNotEmpty);
    final readyLanes = ready.map((t) => t.lane).toSet();
    final wrong = [for (var i = 0; i < 4; i++) i].firstWhere((lane) => !readyLanes.contains(lane));
    expect(game.press(wrong), isNull);
    expect(game.lives, 2);
    expect(game.combo, 0);
  });

  test('missed tiles cost lives until the game is over', () {
    final game = newGame();
    game.press(game.tiles.first.lane);
    for (var i = 0; i < 400 && !game.isOver; i++) {
      game.update(0.1);
    }
    expect(game.isOver, isTrue);
    expect(game.lives, 0);
    expect(game.press(0), isNull);
  });

  test('the game speeds up with the level', () {
    final game = newGame();
    final slow = game.speed;
    game.level = 6;
    expect(game.speed, greaterThan(slow));
    expect(game.speed, lessThanOrEqualTo(1.2));
  });

  test('every song uses scale degrees 0 to 7', () {
    for (final song in MagicTiles.songs) {
      expect(song.every((note) => note >= 0 && note <= 7), isTrue);
    }
  });
}
