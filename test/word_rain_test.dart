import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:typing_academy_desktop/game/word_rain.dart';

void main() {
  test('typing a falling word clears it and scores points', () {
    final game = WordRainGame(words: ['sun', 'moon'], random: Random(1));
    game.update(0.5);
    expect(game.active, isNotEmpty);
    final word = game.active.first.text;
    for (final char in word.split('')) {
      expect(game.handleChar(char), isTrue);
    }
    expect(game.active, isEmpty);
    expect(game.score, greaterThan(0));
    expect(game.cleared, 1);
  });

  test('a wrong letter does not clear a word', () {
    final game = WordRainGame(words: ['sun'], random: Random(1));
    game.update(0.5);
    expect(game.handleChar('z'), isFalse);
    expect(game.active.length, 1);
    expect(game.score, 0);
  });

  test('words that reach the ground cost a life and the game ends', () {
    final game = WordRainGame(words: ['sun'], random: Random(2), lives: 1);
    for (var i = 0; i < 400 && !game.isOver; i++) {
      game.update(0.25);
    }
    expect(game.isOver, isTrue);
    expect(game.lives, 0);
  });
}
