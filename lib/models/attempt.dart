class LessonAttempt {
  const LessonAttempt({
    this.id,
    required this.lessonId,
    required this.startedAt,
    required this.finishedAt,
    required this.durationMs,
    required this.wpm,
    required this.accuracy,
    required this.errors,
    required this.stars,
    required this.completed,
  });

  final int? id;
  final String lessonId;
  final DateTime startedAt;
  final DateTime finishedAt;
  final int durationMs;
  final double wpm;
  final double accuracy;
  final int errors;
  final int stars;
  final bool completed;

  Map<String, dynamic> toMap() => {
        'id': id,
        'lesson_id': lessonId,
        'started_at': startedAt.toIso8601String(),
        'finished_at': finishedAt.toIso8601String(),
        'duration_ms': durationMs,
        'wpm': wpm,
        'accuracy': accuracy,
        'errors': errors,
        'stars': stars,
        'completed': completed ? 1 : 0,
      };

  factory LessonAttempt.fromMap(Map<String, dynamic> map) {
    return LessonAttempt(
      id: map['id'] as int?,
      lessonId: map['lesson_id'] as String,
      startedAt: DateTime.parse(map['started_at'] as String),
      finishedAt: DateTime.parse(map['finished_at'] as String),
      durationMs: map['duration_ms'] as int,
      wpm: (map['wpm'] as num).toDouble(),
      accuracy: (map['accuracy'] as num).toDouble(),
      errors: map['errors'] as int,
      stars: map['stars'] as int,
      completed: (map['completed'] as int) == 1,
    );
  }
}

class LessonProgress {
  const LessonProgress({
    required this.lessonId,
    required this.bestWpm,
    required this.bestAccuracy,
    required this.bestStars,
    required this.attempts,
    required this.completed,
    this.lastAttemptAt,
  });

  final String lessonId;
  final double bestWpm;
  final double bestAccuracy;
  final int bestStars;
  final int attempts;
  final bool completed;
  final DateTime? lastAttemptAt;
}

class UserStats {
  const UserStats({
    required this.totalPracticeMs,
    required this.averageWpm,
    required this.averageAccuracy,
    required this.completedLessons,
    required this.totalStars,
    required this.totalAttempts,
  });

  final int totalPracticeMs;
  final double averageWpm;
  final double averageAccuracy;
  final int completedLessons;
  final int totalStars;
  final int totalAttempts;
}

class Achievement {
  const Achievement({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.icon,
    required this.unlocked,
  });

  final String id;
  final String titleEn;
  final String titleAr;
  final String descriptionEn;
  final String descriptionAr;
  final String icon;
  final bool unlocked;

  String title(bool arabic) => arabic ? titleAr : titleEn;
  String description(bool arabic) => arabic ? descriptionAr : descriptionEn;
}

/// An attempt as listed in the history, with a flag telling whether a replay was stored.
class RecentAttempt {
  const RecentAttempt(this.attempt, this.hasReplay);

  final LessonAttempt attempt;
  final bool hasReplay;
}
