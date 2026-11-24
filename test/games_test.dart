import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:typing_academy_desktop/game/key_hunt.dart';
import 'package:typing_academy_desktop/game/speed_race.dart';
import 'package:typing_academy_desktop/game/word_sprint.dart';

void main() {
  test('word sprint counts words and mistakes, and ends when the clock runs out', () {
    final game = WordSprint(words: ['sun'], random: Random(1), durationSeconds: 10);
    expect(game.isOver, isFalse);
    expect(game.handleChar('x'), isFalse);
    expect(game.mistakes, 1);
    for (final char in 'sun'.split('')) {
      expect(game.handleChar(char), isTrue);
    }
    expect(game.completed, 1);
    expect(game.score, greaterThan(0));
    game.update(11);
    expect(game.isOver, isTrue);
    expect(game.handleChar('s'), isFalse);
  });

  test('word sprint clock only starts with the first key', () {
    final game = WordSprint(words: ['sun'], random: Random(1), durationSeconds: 10);
    game.update(5);
    expect(game.remaining, 10);
  });

  test('speed race: finishing before the ghost wins', () {
    final race = SpeedRace(text: 'abc', ghostWpm: 20);
    for (final char in 'abc'.split('')) {
      expect(race.handleChar(char), isTrue);
    }
    expect(race.isOver, isTrue);
    expect(race.won, isTrue);
    expect(race.score, greaterThanOrEqualTo(100));
  });

  test('speed race: the ghost wins when the player is too slow', () {
    final race = SpeedRace(text: 'abcdef', ghostWpm: 60);
    race.handleChar('a');
    race.update(5);
    expect(race.ghostFinished, isTrue);
    expect(race.won, isFalse);
    expect(race.isOver, isTrue);
  });

  test('key hunt scores hits, penalises misses and shows a hint after a moment', () {
    final game = KeyHunt(keys: ['f', 'j'], random: Random(3), durationSeconds: 10);
    final first = game.current;
    expect(game.hinted, isFalse);
    expect(game.handleChar(first), isTrue);
    expect(game.hits, 1);
    expect(game.score, greaterThanOrEqualTo(12));
    final wrong = game.current == 'f' ? 'j' : 'f';
    expect(game.handleChar(wrong), isFalse);
    expect(game.misses, 1);
    expect(game.streak, 0);
    game.update(1.6);
    expect(game.hinted, isTrue);
    game.update(20);
    expect(game.isOver, isTrue);
  });

  test('key hunt: a key that is not found in time counts as a miss', () {
    final game = KeyHunt(keys: ['f', 'j'], random: Random(4), perKeySeconds: 2, durationSeconds: 30);
    game.handleChar(game.current == 'f' ? 'j' : 'f');
    final before = game.misses;
    game.update(2.5);
    expect(game.misses, before + 1);
  });
}
