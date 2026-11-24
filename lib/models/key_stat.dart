/// Lifetime practice data for one key (the character the learner had to type).
class KeyStat {
  const KeyStat({required this.char, required this.attempts, required this.errors});

  final String char;
  final int attempts;
  final int errors;

  double get errorRate => attempts == 0 ? 0 : errors / attempts;

  double get accuracy => 1 - errorRate;

  String get label => char == ' ' ? '␣' : char;

  Map<String, dynamic> toMap() => {'char': char, 'attempts': attempts, 'errors': errors};

  factory KeyStat.fromMap(Map<String, dynamic> map) {
    return KeyStat(
      char: map['char'] as String,
      attempts: (map['attempts'] as num).toInt(),
      errors: (map['errors'] as num).toInt(),
    );
  }
}
