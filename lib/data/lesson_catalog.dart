import '../models/lesson.dart';
import 'curriculum.dart';

class LessonCatalog {
  /// The full Typing Jungle-style course, generated once at start-up.
  static final List<Lesson> all = Curriculum.build();

  static List<LessonStage> stages() {
    final grouped = <String, List<Lesson>>{};
    for (final lesson in all) {
      grouped.putIfAbsent(lesson.stageId, () => []).add(lesson);
    }
    return grouped.entries.map((entry) {
      final lessons = List<Lesson>.from(entry.value)..sort((a, b) => a.order.compareTo(b.order));
      return LessonStage(
        id: entry.key,
        titleEn: lessons.first.stageTitleEn,
        titleAr: lessons.first.stageTitleAr,
        lessons: lessons,
      );
    }).toList();
  }

  static Lesson? byId(String id) {
    for (final lesson in all) {
      if (lesson.id == id) {
        return lesson;
      }
    }
    return null;
  }

  static Lesson? nextAfter(String id) {
    final index = all.indexWhere((lesson) => lesson.id == id);
    if (index < 0 || index + 1 >= all.length) {
      return null;
    }
    return all[index + 1];
  }
}
