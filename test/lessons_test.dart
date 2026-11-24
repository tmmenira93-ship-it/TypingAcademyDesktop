import 'package:flutter_test/flutter_test.dart';
import 'package:typing_academy_desktop/data/curriculum.dart';
import 'package:typing_academy_desktop/data/lesson_catalog.dart';
import 'package:typing_academy_desktop/models/lesson.dart';
import 'package:typing_academy_desktop/state/app_state.dart';
import 'package:typing_academy_desktop/widgets/keyboard_guide.dart';

void main() {
  test('catalog is a full Typing Jungle-style course', () {
    final all = LessonCatalog.all;
    expect(all.length, greaterThan(380));
    expect(all.first.unlockAfterId, isNull);
    expect(all.first.type, LessonType.intro);
    expect(all.last.id, 'typing-tests-25');
    expect(LessonCatalog.stages().length, 22);
    expect(all.map((lesson) => lesson.id).toSet().length, all.length);
  });

  test('lessons form one unlock chain with sequential numbers', () {
    final all = LessonCatalog.all;
    for (var i = 0; i < all.length; i++) {
      expect(all[i].order, i + 1);
      expect(all[i].unlockAfterId, i == 0 ? isNull : all[i - 1].id);
    }
  });

  test('every lesson text can be typed on the on-screen keyboard and has sane requirements', () {
    for (final lesson in LessonCatalog.all) {
      expect(lesson.targetText.length, inInclusiveRange(8, 130), reason: lesson.id);
      expect(lesson.targetText, lesson.targetText.trim(), reason: lesson.id);
      for (final char in lesson.targetText.split('')) {
        expect(KeyboardGuide.fingerFor(char), isNotNull, reason: '${lesson.id}: "$char"');
      }
      if (lesson.isScored) {
        expect(lesson.goalWpm, greaterThan(lesson.minWpm), reason: lesson.id);
      }
    }
  });

  test('every key pair starts with a score-free introduction', () {
    final intros = LessonCatalog.all.where((lesson) => lesson.type == LessonType.intro).toList();
    expect(intros.length, greaterThanOrEqualTo(40));
    expect(intros.every((lesson) => !lesson.isScored), isTrue);
  });

  test('weak-key text is built from the weak keys', () {
    final text = Curriculum.dynamicText(
      ['q', 'P', '5'],
      {'a', 's', 'd', 'f', 'j', 'k', 'l', 'q', 'p'},
    );
    expect(text, isNotEmpty);
    expect(text.contains('q') || text.contains('P') || text.contains('5'), isTrue);
  });

  test('next lesson helper works', () {
    final next = LessonCatalog.nextAfter('home-row-01');
    expect(next?.id, 'home-row-02');
    expect(LessonCatalog.nextAfter('advanced-11')?.id, 'stories-01');
    expect(LessonCatalog.nextAfter('stories-36')?.id, 'typing-tests-01');
    expect(LessonCatalog.nextAfter('typing-tests-25'), isNull);
  });

  test('unlock rules keep first lesson open', () {
    final state = AppState();
    expect(state.isUnlocked(LessonCatalog.all.first), isTrue);
    expect(state.isUnlocked(LessonCatalog.all[1]), isFalse);
  });
}
