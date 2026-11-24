import 'dart:math';

import '../models/lesson.dart';

/// Original course generator modelled on the structure of TypingClub's
/// "Typing Jungle" plan: home row -> top row -> bottom row -> sentences ->
/// capitals -> common patterns -> numbers -> symbols -> advanced.
/// Every key pair gets a score-free introduction, practice lessons and a review.
/// Lesson texts are generated from the keys learned so far (deterministic seeds).
class Curriculum {
  Curriculum._();

  static const _home = _Section(
    id: 'home-row', titleEn: 'Home Row', titleAr: 'صف الارتكاز',
    minStart: 3, minEnd: 3, goalStart: 8, goalEnd: 10, accuracy: 85,
  );
  static const _top = _Section(
    id: 'top-row', titleEn: 'Top Row', titleAr: 'الصف العلوي',
    minStart: 3, minEnd: 3, goalStart: 10, goalEnd: 10, accuracy: 85,
  );
  static const _bottom = _Section(
    id: 'bottom-row', titleEn: 'Bottom Row', titleAr: 'الصف السفلي',
    minStart: 3, minEnd: 4, goalStart: 10, goalEnd: 12, accuracy: 88,
  );
  static const _basic1 = _Section(
    id: 'basic-1', titleEn: 'Basic Level 1', titleAr: 'المستوى الأساسي 1',
    minStart: 3, minEnd: 13, goalStart: 10, goalEnd: 20, accuracy: 90,
  );
  static const _tricky = _Section(
    id: 'tricky-words', titleEn: 'Tricky Words', titleAr: 'كلمات صعبة',
    minStart: 13, minEnd: 13, goalStart: 20, goalEnd: 20, accuracy: 90,
  );
  static const _shift = _Section(
    id: 'shift-key', titleEn: 'Shift Key', titleAr: 'مفتاح Shift',
    minStart: 3, minEnd: 10, goalStart: 10, goalEnd: 20, accuracy: 90,
  );
  static const _patternsSection = _Section(
    id: 'common-patterns', titleEn: 'Common Patterns', titleAr: 'أنماط شائعة',
    minStart: 10, minEnd: 20, goalStart: 20, goalEnd: 30, accuracy: 90,
  );
  static const _basic2 = _Section(
    id: 'basic-2', titleEn: 'Basic Level 2', titleAr: 'المستوى الأساسي 2',
    minStart: 11, minEnd: 20, goalStart: 21, goalEnd: 30, accuracy: 90,
  );
  static const _wordDrills = _Section(
    id: 'word-drills', titleEn: 'Word Drills', titleAr: 'تمارين الكلمات',
    minStart: 8, minEnd: 15, goalStart: 15, goalEnd: 28, accuracy: 90,
  );
  static const _sentenceBuilder = _Section(
    id: 'sentence-builder', titleEn: 'Sentence Builder', titleAr: 'بناء الجمل',
    minStart: 12, minEnd: 22, goalStart: 22, goalEnd: 35, accuracy: 90,
  );
  static const _stories = _Section(
    id: 'stories', titleEn: 'Stories', titleAr: 'القصص',
    minStart: 20, minEnd: 30, goalStart: 35, goalEnd: 45, accuracy: 90,
  );
  static const _patternsTwo = _Section(
    id: 'patterns-2', titleEn: 'More Patterns', titleAr: 'أنماط إضافية',
    minStart: 10, minEnd: 20, goalStart: 20, goalEnd: 32, accuracy: 90,
  );
  static const _speedDrills = _Section(
    id: 'speed-drills', titleEn: 'Speed Drills', titleAr: 'تمارين السرعة',
    minStart: 15, minEnd: 32, goalStart: 25, goalEnd: 50, accuracy: 90,
  );
  static const _realNumbers = _Section(
    id: 'real-numbers', titleEn: 'Numbers in Real Life', titleAr: 'أرقام من الحياة اليومية',
    minStart: 8, minEnd: 20, goalStart: 18, goalEnd: 35, accuracy: 90,
  );
  static const _codeEmail = _Section(
    id: 'code-email', titleEn: 'Code and Email', titleAr: 'أكواد وبريد إلكتروني',
    minStart: 6, minEnd: 15, goalStart: 14, goalEnd: 28, accuracy: 88,
  );
  static const _everyday = _Section(
    id: 'everyday', titleEn: 'Everyday Sentences', titleAr: 'جمل يومية',
    minStart: 20, minEnd: 30, goalStart: 32, goalEnd: 45, accuracy: 90,
  );
  static const _typingTests = _Section(
    id: 'typing-tests', titleEn: 'Typing Tests', titleAr: 'اختبارات الكتابة',
    minStart: 25, minEnd: 40, goalStart: 40, goalEnd: 60, accuracy: 92,
  );
  static const _numbers = _Section(
    id: 'numbers', titleEn: 'Numbers', titleAr: 'الأرقام',
    minStart: 3, minEnd: 15, goalStart: 10, goalEnd: 25, accuracy: 90,
  );
  static const _basic3 = _Section(
    id: 'basic-3', titleEn: 'Basic Level 3', titleAr: 'المستوى الأساسي 3',
    minStart: 21, minEnd: 30, goalStart: 31, goalEnd: 40, accuracy: 90,
  );
  static const _symbols = _Section(
    id: 'symbols', titleEn: 'Symbols', titleAr: 'الرموز',
    minStart: 3, minEnd: 10, goalStart: 10, goalEnd: 25, accuracy: 90,
  );
  static const _more = _Section(
    id: 'more-symbols', titleEn: 'More Symbols', titleAr: 'رموز إضافية',
    minStart: 3, minEnd: 10, goalStart: 10, goalEnd: 20, accuracy: 90,
  );
  static const _advanced = _Section(
    id: 'advanced', titleEn: 'Advanced', titleAr: 'المستوى المتقدم',
    minStart: 25, minEnd: 30, goalStart: 41, goalEnd: 45, accuracy: 92,
  );

  static const List<String> _homeGroups = ['fj', 'dk', 'sl', 'a;', 'gh'];
  static const List<String> _topGroups = ['ru', 'ei', 'wo', 'qp', 'yt'];
  static const List<String> _bottomGroups = ['vm', 'c,', 'x.', 'z/', 'bn'];
  static const List<String> _capGroups = ['FJDK', 'SLA:', 'GHTY', 'RUEIWOQP', 'VMCZNXB?'];
  static const List<String> _numberGroups = ['47', '38', '29', '10', '56'];
  static const List<String> _symbolGroups = [r'$&', '#*', '@(', '!)', '%^'];
  static const List<String> _moreGroups = ["'\"", '-_', '=+', '[]', '{}', '<>', '`~'];
  static const List<String> _patterns = ['the', 'ing', 'tion', 'and', 'est', 'ear', 'ore', 'ent', 'ter', 'ver'];
  static const List<String> _patternList2 = [
    'ough', 'ight', 'ould', 'ment', 'ness', 'able', 'ous', 'ful', 'ive', 'ly', 'th', 'ch',
    'sh', 'wh', 'str', 'pro', 'con', 'com', 'ex', 'tr', 'gr', 'pl', 'un', 're',
  ];

  static List<Lesson> build() {
    final ctx = _Ctx();
    final lessons = <Lesson>[];
    var order = 0;
    String? previousId;

    void addSection(_Section section, List<_Spec> specs) {
      for (var i = 0; i < specs.length; i++) {
        final spec = specs[i];
        order += 1;
        final id = '${section.id}-${(i + 1).toString().padLeft(2, '0')}';
        lessons.add(Lesson(
          id: id,
          stageId: section.id,
          stageTitleEn: section.titleEn,
          stageTitleAr: section.titleAr,
          order: order,
          titleEn: spec.titleEn,
          titleAr: spec.titleAr,
          instructionsEn: spec.instrEn,
          instructionsAr: spec.instrAr,
          targetText: spec.text,
          goalWpm: _lerp(section.goalStart, section.goalEnd, i, specs.length),
          masteryAccuracy: section.accuracy,
          minWpm: spec.type == LessonType.intro ? 0 : _lerp(section.minStart, section.minEnd, i, specs.length),
          unlockAfterId: previousId,
          type: spec.type,
        ));
        previousId = id;
      }
    }

    addSection(_home, _groupSection(_Kind.keys, _home, _homeGroups, ctx, 1));
    addSection(_top, _groupSection(_Kind.keys, _top, _topGroups, ctx, 2));
    addSection(_bottom, _groupSection(_Kind.keys, _bottom, _bottomGroups, ctx, 3));
    addSection(_basic1, _sentenceSpecs(_basic1Sentences, LessonType.sentences));
    addSection(_tricky, _sentenceSpecs(_trickySentences, LessonType.words));
    addSection(_wordDrills, _wordDrillSpecs(ctx));
    addSection(_shift, _groupSection(_Kind.caps, _shift, _capGroups, ctx, 4));
    addSection(_patternsSection, _patternSpecs(ctx));
    addSection(_patternsTwo, _patternSpecs(ctx, patterns: _patternList2, seed: 8200, source: _allWords));
    addSection(_basic2, _sentenceSpecs(_basic2Sentences, LessonType.sentences));
    addSection(_sentenceBuilder, _sentenceBuilderSpecs());
    addSection(_speedDrills, _speedDrillSpecs());
    addSection(_numbers, _groupSection(_Kind.numbers, _numbers, _numberGroups, ctx, 5));
    addSection(_basic3, _sentenceSpecs(_basic3Sentences, LessonType.sentences));
    addSection(_symbols, _groupSection(_Kind.symbols, _symbols, _symbolGroups, ctx, 6));
    addSection(_more, _groupSection(_Kind.symbols, _more, _moreGroups, ctx, 7, more: true));
    addSection(_realNumbers, _realNumberSpecs());
    addSection(_codeEmail, _codeEmailSpecs());
    addSection(
      _everyday,
      _sentenceSpecs(_everydaySentences, LessonType.sentences, prefixEn: 'Everyday sentence', prefixAr: 'جملة يومية'),
    );
    addSection(_advanced, _sentenceSpecs(_advancedSentences, LessonType.sentences));
    addSection(_stories, _storySpecs());
    addSection(_typingTests, _typingTestSpecs());
    return lessons;
  }

  /// Practice text built from the keys a learner misses most (TypingClub's "dynamic practice").
  static String dynamicText(List<String> weakKeys, Set<String> knownKeys, {Random? random}) {
    final rng = random ?? Random();
    final ctx = _Ctx();
    for (final key in knownKeys) {
      if (_isLower(key)) {
        ctx.letters.add(key);
      }
      if (_isDigit(key) && !ctx.digits.contains(key)) {
        ctx.digits.add(key);
      }
    }
    for (final key in weakKeys) {
      if (_isLower(key)) {
        ctx.letters.add(key);
      }
      if (_isDigit(key) && !ctx.digits.contains(key)) {
        ctx.digits.add(key);
      }
    }
    if (ctx.letters.isEmpty) {
      ctx.letters.addAll(const ['f', 'j']);
    }
    final text = _mixed(weakKeys, ctx, rng, 90);
    return text.isEmpty ? weakKeys.join(' ') : text;
  }

  /// Short words for the Word Rain game, limited to the letters the learner has practised
  /// (falls back to every short word when too few are known).
  static List<String> gameWords(Set<String> knownKeys) {
    final letters = <String>{for (final key in knownKeys) if (_isLower(key)) key};
    final short = _allWords.where((word) => word.length >= 3 && word.length <= 7).toList();
    final known = letters.isEmpty
        ? <String>[]
        : short.where((word) => word.split('').every(letters.contains)).toList();
    return known.length >= 25 ? known : short;
  }

  /// Single letters for the Letter Pop game (practised letters, or the home row for beginners).
  static List<String> gameLetters(Set<String> knownKeys) {
    final letters = <String>[for (final key in knownKeys) if (_isLower(key)) key]..sort();
    return letters.length >= 6 ? letters : const ['a', 's', 'd', 'f', 'j', 'k', 'l', 'g', 'h'];
  }

  /// Keys for the Key Hunt game: practised letters and digits (home row when little is known).
  static List<String> huntKeys(Set<String> knownKeys) {
    final keys = <String>[
      for (final key in knownKeys)
        if (_isLower(key) || _isDigit(key)) key,
    ]..sort();
    return keys.length >= 6 ? keys : const ['a', 's', 'd', 'f', 'j', 'k', 'l', 'g', 'h'];
  }

  /// Sentences for the Speed Race game.
  static List<String> raceTexts() => <String>[
        ..._basic1Sentences,
        ..._basic2Sentences,
        ..._basic3Sentences,
      ];

  // ---------------------------------------------------------------- builders

  static List<_Spec> _groupSection(
    _Kind kind,
    _Section section,
    List<String> groups,
    _Ctx ctx,
    int seed, {
    bool more = false,
  }) {
    final specs = <_Spec>[];
    final sectionKeys = <String>[];
    for (var g = 0; g < groups.length; g++) {
      final keys = groups[g].split('');
      sectionKeys.addAll(keys);
      for (final key in keys) {
        if (_isLower(key)) {
          ctx.letters.add(key);
        }
        if (_isDigit(key) && !ctx.digits.contains(key)) {
          ctx.digits.add(key);
        }
      }
      final rng = Random(seed * 1000 + g);
      final label = _label(keys);
      final intro = _introInstructions(kind, more, label);
      specs.add(_Spec(
        type: LessonType.intro,
        titleEn: kind == _Kind.caps ? 'Capitals $label' : 'Keys $label',
        titleAr: kind == _Kind.caps ? 'حروف كبيرة $label' : 'المفاتيح $label',
        instrEn: intro.$1,
        instrAr: intro.$2,
        text: _drill(keys, ctx, rng, 36),
      ));
      specs.add(_Spec(
        type: LessonType.practice,
        titleEn: 'Practice $label',
        titleAr: 'تدريب $label',
        instrEn: 'Practice $label together with the keys you already know. Accuracy first, then speed.',
        instrAr: 'تدرّب على $label مع المفاتيح التي تعرفها. الدقة أولاً ثم السرعة.',
        text: _mixed(keys, ctx, rng, 52),
      ));
      if (kind == _Kind.keys || kind == _Kind.caps) {
        specs.add(_Spec(
          type: LessonType.practice,
          titleEn: 'Practice $label (2)',
          titleAr: 'تدريب $label (2)',
          instrEn: 'A longer round with $label. Keep your eyes on the screen and your fingers on the home row.',
          instrAr: 'جولة أطول مع $label. أبقِ عينيك على الشاشة وأصابعك على صف الارتكاز.',
          text: _mixed(keys, ctx, rng, 78),
        ));
      }
    }
    specs.add(_Spec(
      type: LessonType.review,
      titleEn: 'Review: ${section.titleEn}',
      titleAr: 'مراجعة: ${section.titleAr}',
      instrEn: 'Review every key of this section. Eyes on the screen, fingers back on the home row after each reach.',
      instrAr: 'راجع كل مفاتيح هذا القسم. العينان على الشاشة والأصابع تعود إلى صف الارتكاز بعد كل مدّ.',
      text: _mixed(sectionKeys, ctx, Random(seed * 1000 + 99), 96),
    ));
    return specs;
  }

  static List<_Spec> _wordDrillSpecs(_Ctx ctx) {
    final specs = <_Spec>[];
    const alphabet = 'abcdefghijklmnopqrstuvwxyz';
    for (var i = 0; i < alphabet.length; i++) {
      final letter = alphabet[i];
      final rng = Random(9000 + i);
      var pool = _wordPool(ctx.letters, focus: [letter]);
      if (pool.length < 3) {
        pool = [...pool, ..._pseudoWords(ctx.letters, rng, 8, must: [letter])];
      }
      final shown = letter.toUpperCase();
      specs.add(_Spec(
        type: LessonType.words,
        titleEn: 'Words with $shown',
        titleAr: 'كلمات فيها $shown',
        instrEn: 'Words that use the letter $shown. Keep a steady rhythm and keep your eyes on the screen.',
        instrAr: 'كلمات تحتوي الحرف $shown. حافظ على إيقاع ثابت وأبقِ عينيك على الشاشة.',
        text: _compose(<List<String>>[pool], const [1], rng, 62),
      ));
    }
    final lengths = <(String, String, bool Function(String))>[
      ('Short words', 'كلمات قصيرة', (String word) => word.length <= 3),
      ('Four-letter words', 'كلمات من 4 حروف', (String word) => word.length == 4),
      ('Five-letter words', 'كلمات من 5 حروف', (String word) => word.length == 5),
      ('Long words', 'كلمات طويلة', (String word) => word.length >= 7),
    ];
    for (var i = 0; i < lengths.length; i++) {
      final rng = Random(9100 + i);
      final pool = _wordPool(ctx.letters).where(lengths[i].$3).toList();
      specs.add(_Spec(
        type: LessonType.words,
        titleEn: lengths[i].$1,
        titleAr: lengths[i].$2,
        instrEn: 'Words of a similar length help you find a smooth rhythm.',
        instrAr: 'الكلمات المتقاربة في الطول تساعدك على إيقاع منتظم.',
        text: _compose(<List<String>>[pool.isEmpty ? _pseudoWords(ctx.letters, rng, 10) : pool], const [1], rng, 72),
      ));
    }
    return specs;
  }

  static List<_Spec> _sentenceBuilderSpecs() {
    final specs = <_Spec>[];
    for (var i = 0; i < 30; i++) {
      final rng = Random(9500 + i);
      var first = _sentence(rng);
      var text = '$first ${_sentence(rng)}';
      for (var attempt = 0; attempt < 30 && (text.length < 60 || text.length > 118); attempt++) {
        first = _sentence(rng);
        text = '$first ${_sentence(rng)}';
      }
      if (text.length > 125) {
        text = first;
      }
      specs.add(_Spec(
        type: LessonType.sentences,
        titleEn: 'Sentence builder ${i + 1}',
        titleAr: 'بناء الجمل ${i + 1}',
        instrEn: 'Two new sentences. Capital letters need the opposite Shift key.',
        instrAr: 'جملتان جديدتان. الحروف الكبيرة تحتاج مفتاح Shift في اليد المقابلة.',
        text: text,
      ));
    }
    return specs;
  }

  static String _sentence(Random rng) {
    String pick(List<String> list) => list[rng.nextInt(list.length)];
    switch (rng.nextInt(3)) {
      case 0:
        return 'The ${pick(_adjectives)} ${pick(_nouns)} ${pick(_pastVerbs)} the ${pick(_adjectives)} ${pick(_nouns)}.';
      case 1:
        final a = pick(_names);
        var b = pick(_names);
        while (b == a) {
          b = pick(_names);
        }
        return '$a and $b ${pick(_pastVerbs)} the ${pick(_nouns)} ${pick(_places)}.';
      default:
        return 'Every ${pick(_nouns)} needs ${pick(_needs)}, and every ${pick(_nouns)} needs ${pick(_needs)}.';
    }
  }

  static List<_Spec> _storySpecs() {
    final specs = <_Spec>[];
    for (final story in _storyData) {
      for (var i = 0; i < story.chapters.length; i++) {
        specs.add(_Spec(
          type: LessonType.sentences,
          titleEn: 'Story: ${story.titleEn} (${i + 1}/${story.chapters.length})',
          titleAr: 'قصة: ${story.titleAr} (${i + 1}/${story.chapters.length})',
          instrEn: 'A short story, one chapter at a time. Type it smoothly and enjoy the plot.',
          instrAr: 'قصة قصيرة فصلاً بعد فصل. اكتبها بسلاسة واستمتع بالأحداث.',
          text: story.chapters[i],
        ));
      }
    }
    return specs;
  }

  static List<_Spec> _speedDrillSpecs() {
    final specs = <_Spec>[];
    for (var i = 0; i < 30; i++) {
      final rng = Random(9700 + i);
      specs.add(_Spec(
        type: LessonType.words,
        titleEn: 'Speed drill ${i + 1}',
        titleAr: 'تمرين سرعة ${i + 1}',
        instrEn: 'Common words, typed fast. Stay accurate first, then push the speed.',
        instrAr: 'كلمات شائعة تُكتب بسرعة. حافظ على الدقة أولاً ثم ارفع السرعة.',
        text: _compose(<List<String>>[_commonWords], const [1], rng, 58 + i),
      ));
    }
    return specs;
  }

  static List<_Spec> _realNumberSpecs() {
    final specs = <_Spec>[];
    for (var i = 0; i < 30; i++) {
      final rng = Random(9800 + i);
      specs.add(_Spec(
        type: LessonType.practice,
        titleEn: 'Real-life numbers ${i + 1}',
        titleAr: 'أرقام من الحياة ${i + 1}',
        instrEn: 'Phone numbers, dates, prices and times. Use the number row without looking.',
        instrAr: 'أرقام هواتف وتواريخ وأسعار وأوقات. استخدم صف الأرقام دون النظر.',
        text: _snippets(rng, _numberSnippet, 2 + (i % 2), 108),
      ));
    }
    return specs;
  }

  static List<_Spec> _codeEmailSpecs() {
    final specs = <_Spec>[];
    for (var i = 0; i < 25; i++) {
      final rng = Random(9850 + i);
      specs.add(_Spec(
        type: LessonType.practice,
        titleEn: 'Code and email ${i + 1}',
        titleAr: 'أكواد وبريد ${i + 1}',
        instrEn: 'Brackets, quotes, operators, addresses: the symbols you meet in real work.',
        instrAr: 'أقواس واقتباسات ومعاملات وعناوين: الرموز التي تقابلها في العمل الحقيقي.',
        text: _snippets(rng, _codeSnippet, 3, 104),
      ));
    }
    return specs;
  }

  static List<_Spec> _typingTestSpecs() {
    final pool = <String>[
      ..._basic2Sentences,
      ..._basic3Sentences,
      ..._everydaySentences,
      ..._advancedSentences,
    ];
    final specs = <_Spec>[];
    for (var i = 0; i < 25; i++) {
      final rng = Random(9900 + i);
      var text = pool[rng.nextInt(pool.length)];
      for (var attempt = 0; attempt < 60; attempt++) {
        final a = pool[rng.nextInt(pool.length)];
        final b = pool[rng.nextInt(pool.length)];
        final length = a.length + 1 + b.length;
        if (a != b && length >= 90 && length <= 125) {
          text = '$a $b';
          break;
        }
      }
      specs.add(_Spec(
        type: LessonType.sentences,
        titleEn: 'Typing test ${i + 1}',
        titleAr: 'اختبار كتابة ${i + 1}',
        instrEn: 'A longer test text. Keep a steady pace from the first letter to the last.',
        instrAr: 'نص اختبار أطول. حافظ على وتيرة ثابتة من أول حرف إلى آخر حرف.',
        text: text,
      ));
    }
    return specs;
  }

  static String _snippets(Random rng, String Function(Random) make, int count, int maxLength) {
    final parts = <String>[];
    for (var i = 0; i < count; i++) {
      final part = make(rng);
      final candidate = <String>[...parts, part].join(' ');
      if (parts.isNotEmpty && candidate.length > maxLength) {
        break;
      }
      parts.add(part);
    }
    return parts.join(' ');
  }

  static String _numberSnippet(Random rng) {
    int n(int low, int high) => low + rng.nextInt(high - low + 1);
    String two(int value) => value.toString().padLeft(2, '0');
    switch (rng.nextInt(8)) {
      case 0:
        return 'Call 555-${n(1000, 9999)} before ${n(1, 11)}:${two(n(0, 59))}.';
      case 1:
        return 'Meet me on ${two(n(1, 12))}/${two(n(1, 28))}/${n(2024, 2030)} at ${n(1, 12)}:${two(n(0, 59))}.';
      case 2:
        return 'The ticket costs \$${n(5, 99)}.${two(n(0, 99))}, and the book costs \$${n(5, 49)}.${two(n(0, 99))}.';
      case 3:
        return 'About ${n(10, 95)}% of the ${n(100, 480)} students passed.';
      case 4:
        return 'The room is ${n(2, 9)}.${n(0, 9)} m wide and ${n(3, 12)}.${n(0, 9)} m long.';
      case 5:
        return 'Open from ${n(6, 9)}:00 to ${n(15, 21)}:30, Monday to Friday.';
      case 6:
        return 'Order #${n(1000, 9999)} ships in ${n(1, 4)}-${n(5, 9)} days.';
      default:
        {
          final a = n(10, 99);
          final b = n(10, 99);
          final c = n(50, 99);
          final d = n(10, 49);
          return '$a + $b = ${a + b} and $c - $d = ${c - d}.';
        }
    }
  }

  static String _codeSnippet(Random rng) {
    String id() => _identifiers[rng.nextInt(_identifiers.length)];
    int n(int low, int high) => low + rng.nextInt(high - low + 1);
    switch (rng.nextInt(10)) {
      case 0:
        return 'let ${id()} = ${id()} * ${n(2, 9)} + ${id()};';
      case 1:
        return 'if (${id()} < ${n(10, 99)}) { print("${id()}"); }';
      case 2:
        return '${id()} = "${id()}"; ${id()} = ${n(1, 99)};';
      case 3:
        return 'for (i = 0; i < ${n(3, 20)}; i++) { ${id()}(); }';
      case 4:
        return 'email: ${id()}.${id()}@mail.com';
      case 5:
        return 'https://www.${id()}.com/${id()}?id=${n(10, 999)}';
      case 6:
        return '${id()}[${n(0, 9)}] = ${id()}_${id()};';
      case 7:
        return 'return a > b ? a : b;';
      case 8:
        return 'x = (a + b) * (c - d) / ${n(2, 9)};';
      default:
        return 'tags: #${id()} @${id()} &${id()} 50% \$10';
    }
  }

  static List<_Spec> _sentenceSpecs(
    List<String> sentences,
    LessonType type, {
    String prefixEn = 'Sentence',
    String prefixAr = 'جملة',
  }) {
    final specs = <_Spec>[];
    for (var i = 0; i < sentences.length; i++) {
      final words = type == LessonType.words;
      specs.add(_Spec(
        type: type,
        titleEn: words ? 'Tricky words ${i + 1}' : '$prefixEn ${i + 1}',
        titleAr: words ? 'كلمات صعبة ${i + 1}' : '$prefixAr ${i + 1}',
        instrEn: words
            ? 'Tricky words: watch the spelling of words that sound alike or are often confused.'
            : 'Type the sentence at a steady rhythm. Fix mistakes calmly and keep your eyes on the screen.',
        instrAr: words
            ? 'كلمات صعبة: انتبه إلى إملاء الكلمات المتشابهة في النطق أو التي يكثر الخلط بينها.'
            : 'اكتب الجملة بإيقاع ثابت. صحّح أخطاءك بهدوء وأبقِ عينيك على الشاشة.',
        text: sentences[i],
      ));
    }
    return specs;
  }

  static List<_Spec> _patternSpecs(
    _Ctx ctx, {
    List<String> patterns = _patterns,
    int seed = 8000,
    List<String>? source,
  }) {
    final specs = <_Spec>[];
    for (var i = 0; i < patterns.length; i++) {
      final pattern = patterns[i];
      final rng = Random(seed + i);
      final containing = (source ?? _words).where((word) => word.contains(pattern)).toList();
      final pool = containing.length >= 3
          ? containing
          : <String>[for (final letter in ctx.letters.take(6)) pattern + letter];
      specs.add(_Spec(
        type: LessonType.patterns,
        titleEn: 'Pattern "$pattern"',
        titleAr: 'النمط "$pattern"',
        instrEn: 'Common letter pattern "$pattern". Typing it as one flowing motion builds speed.',
        instrAr: 'نمط حروف شائع "$pattern". اكتبه كحركة واحدة متصلة لتزداد سرعتك.',
        text: _compose(<List<String>>[
          [pattern],
          pool,
        ], const [2, 6], rng, 64),
      ));
    }
    return specs;
  }

  static (String, String) _introInstructions(_Kind kind, bool more, String label) {
    switch (kind) {
      case _Kind.keys:
        return (
          'New keys: $label. Rest your fingers on the home row (feel the bumps on F and J), look at the screen, and press each highlighted key with the finger shown. You can only continue by pressing the right key.',
          'مفاتيح جديدة: $label. ضع أصابعك على صف الارتكاز (تحسّس النتوءين على F و J) وانظر إلى الشاشة واضغط كل مفتاح مضيء بالإصبع المحدد. لا تتقدم إلا بالمفتاح الصحيح.',
        );
      case _Kind.caps:
        return (
          'New capitals: $label. Hold the Shift key on the opposite hand, press the letter, then return to the home row.',
          'حروف كبيرة جديدة: $label. اضغط Shift بيد معاكسة ليد الحرف ثم الحرف ثم عد إلى صف الارتكاز.',
        );
      case _Kind.numbers:
        return (
          'New number keys: $label. Reach up from the home row with the same finger, press the number, and come back.',
          'مفاتيح أرقام جديدة: $label. مدّ الإصبع نفسه من صف الارتكاز واضغط الرقم ثم عد.',
        );
      case _Kind.symbols:
        return more
            ? (
                'New keys: $label. Where a key shows two symbols, hold Shift on the opposite hand for the upper one. Return to the home row after each reach.',
                'مفاتيح جديدة: $label. عندما يحمل المفتاح رمزين اضغط Shift بيد معاكسة للرمز العلوي ثم عد إلى صف الارتكاز.',
              )
            : (
                'New symbols: $label. Hold Shift on the opposite hand and press the number key, then return to the home row.',
                'رموز جديدة: $label. اضغط Shift بيد معاكسة ثم مفتاح الرقم ثم عد إلى صف الارتكاز.',
              );
    }
  }

  // --------------------------------------------------------- text generators

  static String _drill(List<String> keys, _Ctx ctx, Random rng, int length) {
    final tokens = <String>[];
    for (final key in keys) {
      if (_isUpper(key)) {
        for (final word in _pseudoWords(ctx.letters, rng, 3)) {
          tokens.add(key + word.substring(0, word.length > 3 ? 3 : word.length));
        }
      } else {
        tokens
          ..add(key + key)
          ..add(key + key + key);
      }
    }
    final plain = keys.where((key) => !_isUpper(key)).toList();
    for (var i = 0; i < plain.length; i++) {
      for (var j = 0; j < plain.length; j++) {
        if (i != j) {
          tokens
            ..add(plain[i] + plain[j])
            ..add(plain[i] + plain[j] + plain[i]);
        }
      }
    }
    return _compose(<List<String>>[tokens], const [1], rng, length);
  }

  static String _mixed(List<String> keys, _Ctx ctx, Random rng, int length) {
    final lower = keys.where(_isLower).toList();
    final upper = keys.where(_isUpper).toList();
    final others = keys.where((key) => !_isLower(key) && !_isUpper(key) && key != ' ').toList();
    final all = _wordPool(ctx.letters);
    final base = all.isNotEmpty ? all : _pseudoWords(ctx.letters, rng, 14);
    final pools = <List<String>>[];
    final weights = <int>[];
    if (lower.isNotEmpty) {
      final focus = _wordPool(ctx.letters, focus: lower);
      pools.add(focus.length >= 3 ? focus : _pseudoWords(ctx.letters, rng, 10, must: lower));
      weights.add(6);
    }
    if (upper.isNotEmpty) {
      final caps = <String>[];
      for (final word in base) {
        final initial = word[0].toUpperCase();
        if (upper.contains(initial)) {
          caps.add(initial + word.substring(1));
        }
      }
      if (caps.length < 3) {
        for (final initial in upper) {
          for (final word in _pseudoWords(ctx.letters, rng, 2)) {
            caps.add(initial + word);
          }
        }
      }
      pools.add(caps);
      weights.add(6);
    }
    if (others.isNotEmpty) {
      final focusDigits = others.where(_isDigit).toList();
      final phrases = <String>[];
      for (var i = 0; i < 14; i++) {
        phrases.add(_phrase(others[i % others.length], ctx, rng, base, focusDigits));
      }
      pools.add(phrases);
      weights.add(6);
    }
    pools.add(base);
    weights.add(lower.isNotEmpty || upper.isNotEmpty ? 2 : 1);
    return _compose(pools, weights, rng, length);
  }

  static String _compose(List<List<String>> pools, List<int> weights, Random rng, int length) {
    final total = weights.fold<int>(0, (sum, weight) => sum + weight);
    final buffer = StringBuffer();
    var last = '';
    var guard = 0;
    while (buffer.length < length && guard < 400) {
      guard += 1;
      var roll = rng.nextInt(total);
      var index = 0;
      while (roll >= weights[index]) {
        roll -= weights[index];
        index += 1;
      }
      final pool = pools[index];
      if (pool.isEmpty) {
        continue;
      }
      var token = pool[rng.nextInt(pool.length)];
      if (token == last && pool.length > 1) {
        token = pool[rng.nextInt(pool.length)];
      }
      if (buffer.isNotEmpty) {
        buffer.write(' ');
      }
      buffer.write(token);
      last = token;
    }
    return buffer.toString();
  }

  static String _phrase(String key, _Ctx ctx, Random rng, List<String> words, List<String> focusDigits) {
    final templates = _isDigit(key) ? _digitTemplates : _templates[key];
    if (templates == null) {
      return key + key;
    }
    var text = templates[rng.nextInt(templates.length)];
    while (text.contains('§w')) {
      text = text.replaceFirst('§w', words[rng.nextInt(words.length)]);
    }
    while (text.contains('§n')) {
      text = text.replaceFirst('§n', _number(ctx, rng, focusDigits));
    }
    return text;
  }

  static String _number(_Ctx ctx, Random rng, List<String> focus) {
    final pool = ctx.digits.isEmpty ? const ['7'] : ctx.digits;
    final length = 1 + rng.nextInt(3);
    final buffer = StringBuffer();
    for (var i = 0; i < length; i++) {
      buffer.write(pool[rng.nextInt(pool.length)]);
    }
    final text = buffer.toString();
    if (focus.isNotEmpty && !focus.any((digit) => text.contains(digit))) {
      return focus[rng.nextInt(focus.length)] + text.substring(1);
    }
    return text;
  }

  static List<String> _wordPool(Set<String> letters, {List<String> focus = const [], List<String>? source}) {
    final out = <String>[];
    for (final word in source ?? _words) {
      var allowed = true;
      var hasFocus = focus.isEmpty;
      for (var i = 0; i < word.length; i++) {
        final char = word[i];
        if (!letters.contains(char)) {
          allowed = false;
          break;
        }
        if (!hasFocus && focus.contains(char)) {
          hasFocus = true;
        }
      }
      if (allowed && hasFocus) {
        out.add(word);
      }
    }
    return out;
  }

  static List<String> _pseudoWords(Set<String> letters, Random rng, int count, {List<String> must = const []}) {
    final list = letters.toList()..sort();
    if (list.isEmpty) {
      list.addAll(const ['f', 'j']);
    }
    final out = <String>[];
    for (var i = 0; i < count; i++) {
      final length = 2 + rng.nextInt(3);
      final chars = List<String>.generate(length, (_) => list[rng.nextInt(list.length)]);
      if (must.isNotEmpty) {
        chars[rng.nextInt(length)] = must[rng.nextInt(must.length)];
      }
      out.add(chars.join());
    }
    return out;
  }

  // ----------------------------------------------------------------- helpers

  static int _lerp(int start, int end, int index, int count) {
    if (count <= 1) {
      return start;
    }
    return (start + (end - start) * index / (count - 1)).round();
  }

  static String _label(List<String> keys) {
    final shown = keys.map((key) => _isLower(key) ? key.toUpperCase() : key).toList();
    return shown.length <= 3 ? shown.join(' & ') : shown.join(' ');
  }

  static bool _isLower(String key) => key.length == 1 && key.codeUnitAt(0) >= 97 && key.codeUnitAt(0) <= 122;
  static bool _isUpper(String key) => key.length == 1 && key.codeUnitAt(0) >= 65 && key.codeUnitAt(0) <= 90;
  static bool _isDigit(String key) => key.length == 1 && key.codeUnitAt(0) >= 48 && key.codeUnitAt(0) <= 57;

  // -------------------------------------------------------------------- data

  /// Phrase templates per key. `§w` = a word the learner can already type, `§n` = a number.
  static const Map<String, List<String>> _templates = {
    ',': ['§w, §w', '§w, §w, §w'],
    '.': ['§w §w.', '§w.'],
    ';': ['§w; §w', '§w; §w;'],
    '/': ['§w/§w', '§w/§w/§w'],
    ':': ['§w: §w', '§w:'],
    '?': ['§w §w?', '§w?'],
    r'$': [r'$§n', r'§w $§n'],
    '&': ['§w & §w'],
    '#': ['#§n', '§w #§n'],
    '*': ['§w * §n', '§n * §n'],
    '@': ['§w @ §w', '@§w'],
    '(': ['(§w)', '(§w §w)'],
    ')': ['(§w)', '§w (§w)'],
    '!': ['§w!', '§w §w!'],
    '%': ['§n%', '§w §n%'],
    '^': ['§n^§n'],
    "'": ["§w's", "§w's §w"],
    '"': ['"§w"', '"§w §w"'],
    '-': ['§w-§w', '§n-§n'],
    '_': ['§w_§w', '§w_§n'],
    '=': ['§n = §n', '§w = §n'],
    '+': ['§n + §n', '§w + §w'],
    '[': ['[§w]', '[§n]'],
    ']': ['[§w]', '[§n] §w'],
    '{': ['{§w}', '{§n}'],
    '}': ['{§w}', '{§w §n}'],
    '<': ['§w < §w', '§n < §n'],
    '>': ['§w > §w', '§n > §n'],
    '`': ['`§w`', '`§n`'],
    '~': ['~§n', '§w ~ §w'],
  };

  static const List<String> _digitTemplates = ['room §n', 'page §n', '§n §w', 'day §n', '§w §n'];

  static const List<String> _basic1Sentences = [
    'the sun rises in the east, and it sets in the west.',
    'a cat can jump high, but a dog can run far.',
    'birds fly south in the fall, and they come back in spring.',
    'water is made of two gases, and it can be ice, steam, or rain.',
    'a good friend will listen, help, and share a laugh with you.',
    'the moon moves around the earth, and the earth moves around the sun.',
    'plants need light, water, and air to grow big and strong.',
    'we read books to learn new things, and we write notes to remember them.',
  ];

  static const List<String> _trickySentences = [
    'the boys put their bags over there, and then they went home.',
    'to go too far is not good, but two small steps are fine.',
    'i will buy a gift, then say bye to you and see you by the car.',
    'no, i know the answer, and i will write it right now.',
    'the weather is cold, so i wonder whether we should go.',
    'we sit here to hear the band play near the pier.',
  ];

  static const List<String> _basic2Sentences = [
    'Maria and Peter walk to school every day, and they always say hello.',
    'Tokyo is a big city, but Kyoto is quiet and full of old temples.',
    'What time does the train leave? It leaves at noon.',
    'Dear Sam: thank you for the gift. I will write to you soon.',
    'Africa is a large land. Lions, zebras, and elephants live there.',
    'Can you help Anna find her red scarf? She left it near the lake.',
    'Brazil, Chile, and Peru are in South America.',
    'How does a rainbow form? Sunlight bends inside drops of rain.',
  ];

  static const List<String> _basic3Sentences = [
    'There are 7 days in a week and 12 months in a year.',
    'A spider has 8 legs, and an insect has 6 legs.',
    'The book has 250 pages, and I read 25 pages each day.',
    'Mount Everest is about 8849 meters tall.',
    'Our class has 28 students, and 19 of them like music.',
    'In 1969, people walked on the Moon for the first time.',
    'A day has 24 hours, and an hour has 60 minutes.',
    'The train leaves at 9:30, and the trip takes 2 hours.',
  ];

  static const List<String> _advancedSentences = [
    'Honey never spoils: jars found in old tombs were still safe to eat.',
    "The Pacific Ocean covers about 30% of the Earth's surface.",
    "Light travels at roughly 300,000 km/s, so it's the fastest thing we know.",
    'He said, "Practice makes progress, not perfection!"',
    "Tom & Anna's show starts at 7:45 - don't be late!",
    'The recipe needs 2 cups of flour + 1 cup of sugar = a sweet cake.',
    "Email: team@example.com (replace with your own) - it's free!",
    r"Order #1042 costs $59.99 and ships in 3-5 days.",
    'Great job! You typed 100% of the text without a single mistake.',
    'Use [brackets] for notes and {braces} for sets, and remember: a < b means a is smaller.',
    'The code x_1 = y^2 * 3 is short, but the idea is big.',
  ];

  static const List<String> _adjectives = [
    'small', 'quiet', 'old', 'bright', 'happy', 'clever', 'tall', 'gentle', 'brave', 'curious',
    'sleepy', 'golden', 'friendly', 'swift', 'calm', 'tiny', 'proud', 'lucky',
  ];
  static const List<String> _nouns = [
    'cat', 'dog', 'bird', 'farmer', 'teacher', 'boy', 'girl', 'river', 'garden', 'window', 'robot',
    'sailor', 'baker', 'painter', 'fox', 'turtle', 'rabbit', 'pilot', 'doctor', 'child',
  ];
  static const List<String> _pastVerbs = [
    'chased', 'found', 'painted', 'watched', 'carried', 'visited', 'followed', 'opened', 'cleaned',
    'moved', 'noticed', 'helped', 'remembered', 'surprised', 'greeted',
  ];
  static const List<String> _names = ['Maria', 'Peter', 'Anna', 'Sam', 'Omar', 'Lina', 'Tom', 'Nora'];
  static const List<String> _places = [
    'in the garden', 'near the river', 'after school', 'on Monday', 'before sunrise', 'at the market',
  ];
  static const List<String> _needs = ['water', 'light', 'time', 'care', 'friends', 'rest', 'patience'];

  static const List<_Story> _storyData = [
    _Story('The Lost Kite', 'الطائرة الورقية الضائعة', [
      'On a windy morning, Lina took her red kite to the hill behind the school.',
      'The wind pulled hard, the string slipped away, and the kite floated over the river.',
      'Lina ran after it, and a kind farmer handed it back with a smile.',
    ]),
    _Story('The Little Robot', 'الروبوت الصغير', [
      'In a quiet workshop, a little robot named Bolt woke up and blinked at the sunlight.',
      'Bolt wanted to learn everything, so he read books, counted stars, and asked many questions.',
      'By evening, he knew one big secret: learning is more fun with friends.',
    ]),
    _Story('The Night Market', 'سوق الليل', [
      'Every Friday, the night market filled the street with lights, music, and the smell of warm bread.',
      'Omar sold paper lanterns, and each one glowed a different color.',
      'When the last lantern was gone, he counted 42 coins and grinned all the way home.',
    ]),
    _Story('The Brave Sailor', 'البحّار الشجاع', [
      'Nora sailed a small boat across the bay while the sky turned gray.',
      'Big waves rolled in, but she kept her eyes on the lighthouse and held the rope tight.',
      'At dawn, the storm was gone, and the harbor shone like gold.',
    ]),
    _Story('The Garden Mystery', 'لغز الحديقة', [
      'Each morning, Sam found a new flower in the garden, and nobody knew who planted it.',
      'One night he hid behind the fence and watched quietly under the moon.',
      'A tiny hedgehog dragged a seed across the grass, and the mystery was solved.',
    ]),
    _Story('The Mountain Trip', 'رحلة الجبل', [
      'Peter and his sister climbed the mountain path before sunrise, carrying water, bread, and a map.',
      'Halfway up, fog covered the trail, so they stopped, listened, and followed the sound of a stream.',
      'At the top, the clouds opened, and the whole valley glowed below them.',
    ]),
    _Story('The Snow Day', 'يوم الثلج', [
      'Snow covered the town overnight, and the school bell stayed silent.',
      'Kids built a snowman with a carrot nose, a blue scarf, and two shiny buttons.',
      'By sunset, the snowman was melting, but everyone agreed it was the best day of winter.',
    ]),
    _Story('The Space Postman', 'ساعي بريد الفضاء', [
      'Pilot Ravi delivered letters between the moon and Mars in a tiny silver rocket.',
      'One day, a letter flew out of the window, and Ravi had to chase it through a cloud of stardust.',
      'He caught it just in time, and the happy reader on Mars sent back a thank-you card.',
    ]),
    _Story("The Baker's Secret", 'سرّ الخبّازة', [
      "Every morning, the whole street woke up to the smell of Mina's fresh cinnamon bread.",
      'People asked for her secret, but she only smiled and kept stirring the dough.',
      'At last she whispered it: a little patience, a little love, and a pinch of salt.',
    ]),
    _Story('The Quiet Library', 'المكتبة الهادئة', [
      'At the end of a narrow street stood a library that was always quiet and always warm.',
      'Zara loved the old books, especially the ones with maps, dragons, and secret doors.',
      'One rainy afternoon, she opened a dusty atlas and found a note: Follow the blue line.',
    ]),
    _Story('The Football Match', 'مباراة كرة القدم', [
      'The final match began at 5:30, and the whole village gathered around the field.',
      'The score stayed 1-1 until the last minute, when Leo passed the ball to his sister.',
      'She kicked it high, the crowd held its breath, and the ball slid into the net!',
    ]),
    _Story('The Desert Journey', 'رحلة الصحراء', [
      'A small caravan crossed the desert at night, guided by the stars and a steady wind.',
      'At noon, the travelers rested in the shade of a rock and shared dates and cold tea.',
      'When the oasis finally appeared, the children laughed, and the camels drank deeply.',
    ]),
  ];

  static const List<String> _identifiers = [
    'total', 'price', 'count', 'name', 'value', 'items', 'index', 'score', 'speed', 'level', 'result',
    'width', 'height', 'limit', 'tax', 'user', 'size', 'color', 'mail', 'order',
  ];

  static const List<String> _commonWords = [
    'the', 'of', 'and', 'to', 'in', 'is', 'you', 'that', 'it', 'he', 'was', 'for', 'on', 'are', 'as',
    'with', 'his', 'they', 'at', 'be', 'this', 'have', 'from', 'or', 'one', 'had', 'by', 'but', 'not',
    'what', 'all', 'were', 'we', 'when', 'your', 'can', 'said', 'there', 'use', 'an', 'each', 'which',
    'she', 'do', 'how', 'their', 'if', 'will', 'up', 'other', 'about', 'out', 'many', 'then', 'them',
    'these', 'so', 'some', 'her', 'would', 'make', 'like', 'him', 'into', 'time', 'has', 'look', 'two',
    'more', 'write', 'go', 'see', 'number', 'no', 'way', 'could', 'people', 'my', 'than', 'first',
    'water', 'been', 'call', 'who', 'its', 'now', 'find', 'long', 'down', 'day', 'did', 'get', 'come',
    'made', 'may', 'part',
  ];

  static const List<String> _everydaySentences = [
    "Please remember to drink water, eat breakfast, and take a short walk every day.",
    "The bus to the city center leaves at 7:45, so we should hurry.",
    "My grandmother makes the best soup, and she always adds a little lemon.",
    "Could you tell me where the nearest post office is?",
    "Reading for 20 minutes before bed helps many people sleep better.",
    "The museum is open from 9:00 to 17:00, and children enter for free on Sundays.",
    "It's raining again, so I'll take an umbrella and wear my old boots.",
    "Learning to type well saves hours of time every single week.",
    'She said, "See you tomorrow," and hurried to the station.',
    "The recipe needs 3 eggs, 250 grams of flour, and a cup of milk.",
    "Our team won 4 games in a row, and the coach was proud of everyone.",
    "Cats sleep for about 15 hours a day, and dogs sleep for about 12.",
    "A balanced meal has vegetables, protein, and something sweet at the end.",
    "Wow, that was a great performance! Everyone stood up and clapped.",
    "Where did you put the keys? I looked on the table and in the kitchen.",
    "The train from Cairo to Alexandria takes about 2 hours and 30 minutes.",
    "Don't forget: tomorrow's meeting starts at 10:15 in the blue room.",
    "He opened the window, and the smell of fresh bread filled the room.",
    "Children learn fastest when they play, ask questions, and try again.",
    "The library lets you borrow 5 books for 3 weeks, and you can renew them online.",
    "On weekends, we visit the market, buy fruit, and have lunch by the river.",
    "Sound travels faster in water than in air, which is why whales hear so far.",
    "Be kind, be patient, and remember that everyone is still learning.",
    "The old clock in the hall rings every hour, even in the middle of the night.",
    "A good habit takes about 66 days to form, but only one day to start.",
    "The festival begins on Friday evening and ends on Sunday afternoon.",
    "She packed a map, a flashlight, two sandwiches, and a bottle of water.",
    "What's your favorite season? Mine is autumn, when the leaves turn gold.",
    "Typing without looking at the keys is a skill that anyone can learn.",
    "The shop on the corner sells fresh juice, warm bread, and cold milk.",
    "Honey bees visit about 2 million flowers to make a single pound of honey.",
    "It's important to rest your wrists and stretch your fingers during long practice.",
    "My brother lives in a small town near the sea, and we visit him every summer.",
    "The movie starts at 8:20, so let's meet at the entrance at 8:00.",
    "Turn left at the bakery, walk past the park, and you'll see the school.",
    "Water the plants twice a week, and keep them near a bright window.",
    "Accuracy first, speed second: that's the secret of fast typing.",
    "The mountain village has only 120 houses, but everyone knows everyone.",
    "After the storm, the sky cleared, and a bright rainbow appeared over the hills.",
    "Practice a little every day, and soon your fingers will move without thinking.",
  ];

  static const List<String> _extraWords = [
    'though', 'through', 'thought', 'bought', 'brought', 'rough', 'tough', 'enough', 'cough', 'dough',
    'ought', 'drought', 'light', 'night', 'right', 'fight', 'might', 'sight', 'tight', 'bright',
    'tonight', 'delight', 'height', 'could', 'would', 'should', 'garment', 'basement', 'payment',
    'movement', 'treatment', 'shipment', 'argument', 'element', 'comment', 'department', 'kindness',
    'darkness', 'happiness', 'business', 'illness', 'fitness', 'sadness', 'softness', 'weakness',
    'able', 'cable', 'stable', 'capable', 'usable', 'valuable', 'reliable', 'comfortable', 'enable',
    'readable', 'famous', 'nervous', 'serious', 'curious', 'dangerous', 'generous', 'jealous',
    'mysterious', 'various', 'obvious', 'careful', 'helpful', 'joyful', 'grateful', 'powerful',
    'peaceful', 'colorful', 'useful', 'painful', 'wonderful', 'beautiful', 'active', 'native',
    'creative', 'positive', 'relative', 'motive', 'detective', 'expensive', 'quickly', 'slowly',
    'gently', 'softly', 'happily', 'daily', 'lovely', 'lonely', 'friendly', 'thank', 'three', 'throw',
    'thirty', 'truth', 'month', 'north', 'south', 'smooth', 'birthday', 'chair', 'chase', 'cheese',
    'child', 'church', 'choose', 'change', 'chance', 'reach', 'teach', 'watch', 'catch', 'shine',
    'shape', 'share', 'sharp', 'ship', 'shirt', 'shoe', 'shop', 'short', 'show', 'fish', 'wish',
    'push', 'brush', 'finish', 'where', 'white', 'whale', 'wheel', 'while', 'whisper', 'whole',
    'strong', 'street', 'strange', 'stream', 'strike', 'straight', 'stripe', 'struggle', 'structure',
    'problem', 'project', 'protect', 'provide', 'proud', 'program', 'promise', 'produce', 'process',
    'prove', 'contain', 'contest', 'control', 'continue', 'convert', 'concert', 'connect', 'consider',
    'contact', 'content', 'common', 'complete', 'company', 'compare', 'comfort', 'community',
    'complex', 'combine', 'example', 'explain', 'expect', 'expert', 'extra', 'exit', 'exercise',
    'express', 'exchange', 'train', 'tree', 'trip', 'truck', 'trust', 'trade', 'track', 'trouble',
    'true', 'green', 'group', 'grow', 'grape', 'gray', 'great', 'plan', 'plant', 'play', 'place',
    'please', 'plain', 'plate', 'plus', 'plenty', 'under', 'until', 'unit', 'unique', 'unusual',
    'unlock', 'unhappy', 'return', 'repeat', 'replace', 'remember', 'reason', 'record', 'reduce',
    'relax', 'reply', 'report',
  ];

  static final List<String> _allWords = <String>{..._words, ..._extraWords}.toList();

  static const List<String> _words = [
    'a', 'as', 'ask', 'add', 'ads', 'all', 'fall', 'hall', 'flag', 'flask', 'salad', 'glad', 'had', 'has',
    'dad', 'lad', 'gas', 'sad', 'lag', 'jag', 'dash', 'gash', 'lash', 'hash', 'half', 'shall', 'slash',
    'flash', 'sass', 'fads', 'gals', 'lads', 'sag', 'gag', 'hag', 'dag', 'all', 'ash',
    'the', 'and', 'that', 'with', 'have', 'this', 'from', 'they', 'will', 'would', 'there', 'their',
    'what', 'about', 'which', 'when', 'make', 'like', 'time', 'just', 'know', 'take', 'people', 'into',
    'year', 'your', 'good', 'some', 'could', 'them', 'see', 'other', 'than', 'then', 'now', 'look',
    'only', 'come', 'its', 'over', 'think', 'also', 'back', 'after', 'use', 'two', 'how', 'our', 'work',
    'first', 'well', 'way', 'even', 'new', 'want', 'because', 'any', 'these', 'give', 'day', 'most',
    'apple', 'bread', 'cloud', 'dance', 'earth', 'field', 'grass', 'heart', 'island', 'juice', 'kite',
    'lemon', 'music', 'night', 'ocean', 'paper', 'queen', 'river', 'stone', 'table', 'uncle', 'voice',
    'water', 'yellow', 'zebra', 'window', 'garden', 'family', 'friend', 'school', 'summer', 'winter',
    'spring', 'autumn', 'forest', 'mountain', 'bridge', 'camera', 'doctor', 'engine', 'flower', 'guitar',
    'hammer', 'jacket', 'kitchen', 'ladder', 'market', 'orange', 'pencil', 'rabbit', 'silver', 'ticket',
    'valley', 'wonder', 'animal', 'basket', 'castle', 'desert', 'effort', 'flight', 'ground', 'hunter',
    'insect', 'jungle', 'knight', 'letter', 'matter', 'number', 'object', 'planet', 'rocket', 'simple',
    'travel', 'wisdom',
    'either', 'mother', 'father', 'brother', 'weather', 'gather', 'rather', 'feather', 'leather',
    'together', 'clothes', 'whether', 'another',
    'ring', 'sing', 'king', 'bring', 'thing', 'going', 'being', 'doing', 'string', 'morning', 'evening',
    'building', 'reading', 'writing', 'singing', 'jumping', 'running', 'playing', 'looking',
    'nation', 'action', 'station', 'motion', 'section', 'fiction', 'question', 'mention', 'caution',
    'lotion', 'potion', 'option', 'portion', 'vacation', 'education', 'attention', 'collection',
    'direction', 'addition', 'solution',
    'hand', 'land', 'band', 'stand', 'sand', 'grand', 'brand', 'understand', 'thousand', 'candy', 'handle',
    'command', 'demand', 'expand',
    'best', 'test', 'rest', 'west', 'nest', 'fastest', 'honest', 'guest', 'chest', 'quest', 'request',
    'interest', 'harvest', 'biggest', 'closest', 'greatest', 'tallest', 'strongest',
    'ear', 'near', 'hear', 'bear', 'early', 'clear', 'dear', 'fear', 'gear', 'pear', 'wear', 'tear',
    'learn', 'heard', 'search', 'yearly', 'nearly',
    'more', 'store', 'before', 'score', 'core', 'shore', 'ignore', 'explore', 'wore', 'bore', 'sore',
    'snore', 'restore', 'therefore', 'ashore', 'tore',
    'went', 'sent', 'spent', 'event', 'moment', 'present', 'student', 'parent', 'recent', 'silent', 'bent',
    'cent', 'dent', 'rent', 'tent', 'accident', 'different', 'excellent', 'instrument', 'document',
    'statement', 'agreement',
    'enter', 'sister', 'center', 'monster', 'butter', 'faster', 'later', 'master', 'computer', 'chapter',
    'quarter', 'shelter', 'cluster', 'terrible',
    'ever', 'very', 'cover', 'driver', 'lover', 'several', 'however', 'forever', 'discover', 'deliver',
    'fever', 'clover', 'server', 'universe', 'every',
  ];
}

enum _Kind { keys, caps, numbers, symbols }

class _Section {
  const _Section({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.minStart,
    required this.minEnd,
    required this.goalStart,
    required this.goalEnd,
    required this.accuracy,
  });

  final String id;
  final String titleEn;
  final String titleAr;
  final int minStart;
  final int minEnd;
  final int goalStart;
  final int goalEnd;
  final double accuracy;
}

class _Spec {
  const _Spec({
    required this.type,
    required this.titleEn,
    required this.titleAr,
    required this.instrEn,
    required this.instrAr,
    required this.text,
  });

  final LessonType type;
  final String titleEn;
  final String titleAr;
  final String instrEn;
  final String instrAr;
  final String text;
}

class _Ctx {
  final Set<String> letters = <String>{};
  final List<String> digits = <String>[];
}

class _Story {
  const _Story(this.titleEn, this.titleAr, this.chapters);

  final String titleEn;
  final String titleAr;
  final List<String> chapters;
}
