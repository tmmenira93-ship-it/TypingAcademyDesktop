/// Kinds of lesson, modelled on TypingClub's Typing Jungle course.
enum LessonType { intro, practice, review, patterns, words, sentences, weakKeys }

class Lesson {
  const Lesson({
    required this.id,
    required this.stageId,
    required this.stageTitleEn,
    required this.stageTitleAr,
    required this.order,
    required this.titleEn,
    required this.titleAr,
    required this.instructionsEn,
    required this.instructionsAr,
    required this.targetText,
    required this.goalWpm,
    required this.masteryAccuracy,
    this.unlockAfterId,
    this.type = LessonType.practice,
    this.minWpm = 0,
  });

  final String id;
  final String stageId;
  final String stageTitleEn;
  final String stageTitleAr;
  final int order;
  final String titleEn;
  final String titleAr;
  final String instructionsEn;
  final String instructionsAr;
  final String targetText;
  final int goalWpm;
  final double masteryAccuracy;
  final String? unlockAfterId;
  final LessonType type;

  /// Minimum speed needed to pass (goalWpm is the speed that earns the higher stars).
  final int minWpm;

  /// Key-introduction lessons are score-free: no stars, finishing the text is enough.
  bool get isScored => type != LessonType.intro;

  String title(bool arabic) => arabic ? titleAr : titleEn;
  String instructions(bool arabic) => arabic ? instructionsAr : instructionsEn;
  String stageTitle(bool arabic) => arabic ? stageTitleAr : stageTitleEn;

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      stageId: json['stageId'] as String,
      stageTitleEn: json['stageTitleEn'] as String,
      stageTitleAr: json['stageTitleAr'] as String,
      order: json['order'] as int,
      titleEn: json['titleEn'] as String,
      titleAr: json['titleAr'] as String,
      instructionsEn: json['instructionsEn'] as String,
      instructionsAr: json['instructionsAr'] as String,
      targetText: json['targetText'] as String,
      goalWpm: json['goalWpm'] as int,
      masteryAccuracy: (json['masteryAccuracy'] as num).toDouble(),
      unlockAfterId: json['unlockAfterId'] as String?,
      type: LessonType.values.firstWhere(
        (value) => value.name == json['type'],
        orElse: () => LessonType.practice,
      ),
      minWpm: (json['minWpm'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'stageId': stageId,
        'stageTitleEn': stageTitleEn,
        'stageTitleAr': stageTitleAr,
        'order': order,
        'titleEn': titleEn,
        'titleAr': titleAr,
        'instructionsEn': instructionsEn,
        'instructionsAr': instructionsAr,
        'targetText': targetText,
        'goalWpm': goalWpm,
        'masteryAccuracy': masteryAccuracy,
        'unlockAfterId': unlockAfterId,
        'type': type.name,
        'minWpm': minWpm,
      };
}

class LessonStage {
  const LessonStage({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.lessons,
  });

  final String id;
  final String titleEn;
  final String titleAr;
  final List<Lesson> lessons;

  String title(bool arabic) => arabic ? titleAr : titleEn;
}
