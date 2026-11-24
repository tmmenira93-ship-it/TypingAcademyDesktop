class S {
  S(this.code);

  final String code;

  bool get isArabic => code == 'ar';

  String get appName => isArabic ? 'أكاديمية الكتابة' : 'Typing Academy';
  String get startLearning => isArabic ? 'ابدأ التعلم' : 'Start Learning';
  String get tagline => isArabic
      ? 'تعلّم الكتابة باللمس على حاسوبك دون إنترنت.'
      : 'Learn touch typing on your desktop, offline.';
  String get home => isArabic ? 'الرئيسية' : 'Home';
  String get lessons => isArabic ? 'الدروس' : 'Lessons';
  String get statistics => isArabic ? 'الإحصائيات' : 'Statistics';
  String get achievements => isArabic ? 'الإنجازات' : 'Achievements';
  String get settings => isArabic ? 'الإعدادات' : 'Settings';
  String get help => isArabic ? 'المساعدة' : 'Help';
  String get language => isArabic ? 'اللغة ولوحة المفاتيح' : 'Language & Keyboard';
  String get continueLesson => isArabic ? 'متابعة الدرس' : 'Continue lesson';
  String get startLesson => isArabic ? 'ابدأ الدرس' : 'Start lesson';
  String get lastLesson => isArabic ? 'آخر درس' : 'Last lesson';
  String get yourLevel => isArabic ? 'مستواك' : 'Your level';
  String get progress => isArabic ? 'التقدم' : 'Progress';
  String get noProgressYet =>
      isArabic ? 'لم تبدأ بعد. اختر درسًا للانطلاق.' : 'No progress yet. Pick a lesson to begin.';
  String get wpm => isArabic ? 'كلمة/دقيقة' : 'WPM';
  String get accuracy => isArabic ? 'الدقة' : 'Accuracy';
  String get errors => isArabic ? 'الأخطاء' : 'Errors';
  String get time => isArabic ? 'الوقت' : 'Time';
  String get pause => isArabic ? 'إيقاف مؤقت' : 'Pause';
  String get resume => isArabic ? 'استئناف' : 'Resume';
  String get retry => isArabic ? 'إعادة المحاولة' : 'Try again';
  String get finish => isArabic ? 'إنهاء' : 'Finish';
  String get nextLesson => isArabic ? 'الدرس التالي' : 'Next lesson';
  String get backToMap => isArabic ? 'خريطة الدروس' : 'Lesson map';
  String get locked => isArabic ? 'مقفل' : 'Locked';
  String get completed => isArabic ? 'مكتمل' : 'Completed';
  String get review => isArabic ? 'مراجعة' : 'Review';
  String get english => isArabic ? 'الإنجليزية' : 'English';
  String get arabic => isArabic ? 'العربية' : 'Arabic';
  String get qwerty => 'QWERTY';
  String get arabicLayout => isArabic ? 'عربي' : 'Arabic';
  String get theme => isArabic ? 'المظهر' : 'Theme';
  String get systemTheme => isArabic ? 'تلقائي' : 'System';
  String get lightTheme => isArabic ? 'فاتح' : 'Light';
  String get darkTheme => isArabic ? 'داكن' : 'Dark';
  String get fontSize => isArabic ? 'حجم النص' : 'Text size';
  String get backup => isArabic ? 'نسخة احتياطية' : 'Backup';
  String get restore => isArabic ? 'استعادة' : 'Restore';
  String get deleteHistory => isArabic ? 'حذف سجل التدريب' : 'Delete training history';
  String get backupDone => isArabic ? 'تم حفظ النسخة الاحتياطية محليًا.' : 'Local backup saved.';
  String get restoreDone => isArabic ? 'تمت استعادة البيانات.' : 'Data restored.';
  String get historyDeleted => isArabic ? 'تم حذف السجل.' : 'Training history deleted.';
  String get privacyNote => isArabic
      ? 'بياناتك تبقى على هذا الجهاز. لا يرسل التطبيق شيئًا إلى الإنترنت.'
      : 'Your data stays on this device. The app never sends training data online.';
  String get resultsTitle => isArabic ? 'نتيجة الدرس' : 'Lesson results';
  String get encouragement => isArabic ? 'أحسنت، استمر بتركيز على الدقة.' : 'Nice work. Keep focusing on accuracy.';
  String get tryAccuracy => isArabic
      ? 'الدقة أهم من السرعة. أعد المحاولة بهدوء.'
      : 'Accuracy matters more than speed. Try again slowly.';
  String get stars => isArabic ? 'نجوم' : 'Stars';
  String get totalTime => isArabic ? 'إجمالي وقت التدريب' : 'Total practice time';
  String get avgWpm => isArabic ? 'متوسط السرعة' : 'Average WPM';
  String get avgAccuracy => isArabic ? 'متوسط الدقة' : 'Average accuracy';
  String get needsReview => isArabic ? 'يحتاج مراجعة' : 'Needs review';
  String get helpTitle => isArabic ? 'دليل الاستخدام' : 'User guide';
  String get helpBody => isArabic
      ? 'ضع أصابعك على صف الارتكاز. اكتب النص الظاهر. اللون الأخضر صحيح، والأحمر خطأ. يمكنك التصحيح بمفتاح Backspace. التقدم يُحفظ تلقائيًا على جهازك.'
      : 'Rest your fingers on the home row. Type the shown text. Green is correct, red is a mistake. Use Backspace to correct. Progress is saved automatically on this computer.';
  String get stage => isArabic ? 'مرحلة' : 'Stage';
  String get goal => isArabic ? 'الهدف' : 'Goal';
  String get best => isArabic ? 'أفضل نتيجة' : 'Best';
  String get attempts => isArabic ? 'المحاولات' : 'Attempts';
  String get none => isArabic ? 'لا يوجد' : 'None';
  String get confirmDelete => isArabic ? 'حذف كل نتائج التدريب من هذا الجهاز؟' : 'Delete all training results on this device?';
  String get cancel => isArabic ? 'إلغاء' : 'Cancel';
  String get confirm => isArabic ? 'تأكيد' : 'Confirm';
  String get paused => isArabic ? 'متوقف مؤقتًا' : 'Paused';
  String get typeToBegin => isArabic ? 'ابدأ الكتابة لتشغيل المؤقت' : 'Start typing to begin the timer';
  String get offlineReady => isArabic ? 'يعمل دون إنترنت' : 'Works offline';
  String get chooseLanguage => isArabic ? 'اختر لغة التدريب' : 'Choose practice language';
  String get save => isArabic ? 'حفظ' : 'Save';
  String get beginner => isArabic ? 'مبتدئ' : 'Beginner';
  String get learner => isArabic ? 'متعلم' : 'Learner';
  String get typist => isArabic ? 'كاتب' : 'Typist';
  String get expert => isArabic ? 'محترف' : 'Expert';

  String get practiceOptions => isArabic ? 'خيارات التدريب' : 'Practice options';
  String get showKeyboardGuide => isArabic ? 'إظهار لوحة المفاتيح الإرشادية' : 'Show the on-screen keyboard guide';
  String get showLiveStats => isArabic ? 'إظهار السرعة والدقة أثناء الكتابة' : 'Show live speed and accuracy';
  String get allowBackspace => isArabic ? 'السماح بمفتاح Backspace للتصحيح' : 'Allow Backspace to correct mistakes';
  String get requirements => isArabic ? 'نتيجتك مقابل المتطلبات' : 'Your result vs. requirements';
  String get blockOnError => isArabic ? 'حجب الخطأ: لا تتقدم إلا بالمفتاح الصحيح' : 'Block on error: only the right key moves on';
  String get introLabel => isArabic ? 'تمهيدي' : 'Intro';
  String get introNoScore => isArabic ? 'درس تمهيدي بلا درجات' : 'Introduction - no score';
  String get introDone => isArabic ? 'أحسنت! أنهيت الدرس التمهيدي. تابع إلى التدريب.' : 'Well done! Introduction complete. On to the practice.';
  String get weakKeysTitle => isArabic ? 'تدريب المفاتيح الضعيفة' : 'Weak keys practice';
  String get weakKeysSubtitle => isArabic ? 'درس يُبنى من المفاتيح التي تخطئ فيها أكثر' : 'A lesson built from the keys you miss most';
  String get practiceNow => isArabic ? 'ابدأ التدريب' : 'Practice now';
  String get minSpeedReq => isArabic ? 'الحد الأدنى للسرعة (كلمة/د)' : 'Minimum speed (WPM)';
  String get goalSpeedReq => isArabic ? 'سرعة الهدف للنجوم الأعلى (كلمة/د)' : 'Goal speed for more stars (WPM)';
  String get minAccuracyReq => isArabic ? 'الحد الأدنى للدقة' : 'Minimum accuracy';
  String get showHandsGuide => isArabic ? 'إظهار دليل اليدين (عند توفر مساحة)' : 'Show the hands guide (when there is room)';
  String get keySoundsLabel => isArabic ? 'أصوات المفاتيح' : 'Key sounds';
  String get gamesTitle => isArabic ? 'ألعاب' : 'Games';
  String get gameName => isArabic ? 'مطر الكلمات' : 'Word Rain';
  String get gameDescription => isArabic ? 'اكتب الكلمات المتساقطة قبل أن تصل إلى الأرض.' : 'Type the falling words before they reach the ground.';
  String get playGame => isArabic ? 'العب' : 'Play';
  String get gameScore => isArabic ? 'النقاط' : 'Score';
  String get gameBestScore => isArabic ? 'الأفضل' : 'Best';
  String get gameLevel => isArabic ? 'المستوى' : 'Level';
  String get gameOver => isArabic ? 'انتهت اللعبة' : 'Game over';
  String get playAgain => isArabic ? 'العب مرة أخرى' : 'Play again';
  String get watchReplay => isArabic ? 'مشاهدة إعادة المحاولة' : 'Watch replay';
  String get replayTitle => isArabic ? 'إعادة المحاولة' : 'Replay';
  String get keysBreakdown => isArabic ? 'مفاتيحك' : 'Your keys';
  String get fingersBreakdown => isArabic ? 'أصابعك' : 'Your fingers';
  String get noKeyData => isArabic ? 'تدرّب على بضعة دروس لتظهر إحصاءات مفاتيحك.' : 'Practise a few lessons to see your key statistics.';
  String get voiceOverLabel => isArabic ? 'تعليق صوتي: قراءة تعليمات الدرس بصوت النظام' : 'Voice-over: read lesson instructions with the system voice';
  String get letterPopName => isArabic ? 'فقاعات الحروف' : 'Letter Pop';
  String get letterPopDescription => isArabic ? 'اضغط الحروف المتساقطة قبل أن تصل إلى الأرض.' : 'Press the falling letters before they reach the ground.';
  String get raceName => isArabic ? 'سباق السرعة' : 'Speed Race';
  String get raceDescription => isArabic ? 'تسابق مع شبح يكتب بمتوسط سرعتك.' : 'Race a ghost that types at your own average speed.';
  String get sprintName => isArabic ? 'سباق الكلمات' : 'Word Sprint';
  String get sprintDescription => isArabic ? 'اكتب أكبر عدد من الكلمات خلال 60 ثانية.' : 'Type as many words as you can in 60 seconds.';
  String get youLabel => isArabic ? 'أنت' : 'You';
  String get ghostLabel => isArabic ? 'الشبح' : 'Ghost';
  String get raceWon => isArabic ? 'فزت بالسباق!' : 'You won the race!';
  String get raceLost => isArabic ? 'سبقك الشبح. حاول مجدداً.' : 'The ghost was faster. Try again.';
  String get timeLeft => isArabic ? 'الوقت المتبقي' : 'Time left';
  String get mistakesLabel => isArabic ? 'أخطاء' : 'Mistakes';
  String get wordsLabel => isArabic ? 'كلمات' : 'Words';
  String get recentAttempts => isArabic ? 'آخر المحاولات' : 'Recent attempts';
  String get noRecent => isArabic ? 'لا توجد محاولات بعد.' : 'No attempts yet.';
  String get huntName => isArabic ? 'صيد المفاتيح' : 'Key Hunt';
  String get huntDescription => isArabic ? 'ابحث عن المفتاح على لوحة المفاتيح واضغطه قبل أن ينتهي وقته.' : 'Find the key on the keyboard and press it before its time runs out.';
  String get streakLabel => isArabic ? 'التتابع' : 'Streak';
  String get dailyGoal => isArabic ? 'الهدف اليومي' : 'Daily goal';
  String get minutesShort => isArabic ? 'د' : 'min';
  String get streakDaysLabel => isArabic ? 'أيام متتالية' : 'day streak';
  String get goalReached => isArabic ? 'أنجزت هدف اليوم!' : 'Daily goal reached!';
  String get goalKeepGoing => isArabic ? 'تدرّب قليلاً لتبلغ هدفك.' : 'A little practice gets you there.';
  String get settingsAppearance => isArabic ? 'المظهر' : 'Appearance';
  String get settingsGuides => isArabic ? 'الإرشادات على الشاشة' : 'On-screen guides';
  String get settingsFeedback => isArabic ? 'الصوت والتغذية الراجعة' : 'Sound and feedback';
  String get settingsRules => isArabic ? 'قواعد التدريب' : 'Practice rules';
  String get settingsData => isArabic ? 'بياناتك' : 'Your data';
  String get unlockedLabel => isArabic ? 'مفتوحة' : 'unlocked';
  String get newBest => isArabic ? 'رقم شخصي جديد!' : 'New personal best!';
  String get resultComplete => isArabic ? 'اكتمل الدرس!' : 'Lesson complete!';
  String get resultTryAgain => isArabic ? 'لم تكتمل بعد' : 'Not quite yet';
  String get speedTrend => isArabic ? 'اتجاه السرعة (كلمة/د)' : 'Speed trend (WPM)';
  String get accuracyTrend => isArabic ? 'اتجاه الدقة (%)' : 'Accuracy trend (%)';
  String get courseProgress => isArabic ? 'تقدّم المنهج' : 'Course progress';
  String get lessonsDone => isArabic ? 'درساً منجزاً' : 'lessons done';
  String get magicTilesName => isArabic ? 'البيانو السحري' : 'Magic Tiles';
  String get magicTilesDescription => isArabic ? 'اضغط D أو F أو J أو K عندما تصل البلاطة إلى الأسفل واعزف اللحن.' : 'Press D, F, J or K as the tile reaches the bottom and play the song.';
  String get tilesHint => isArabic ? 'اضغط مفتاح البلاطة السفلى لتبدأ (D F J K)' : 'Hit the lowest tile to start (D F J K)';
  String get fingerHint => isArabic ? 'الإصبع' : 'Finger';
  String get completedLabel => isArabic ? 'مكتمل' : 'Completed';
  String get currentLabel => isArabic ? 'التالي' : 'Up next';

  String fingerName(String code) {
    switch (code) {
      case 'LP':
        return isArabic ? 'الخنصر الأيسر' : 'Left pinky';
      case 'LR':
        return isArabic ? 'البنصر الأيسر' : 'Left ring';
      case 'LM':
        return isArabic ? 'الوسطى اليسرى' : 'Left middle';
      case 'LI':
        return isArabic ? 'السبابة اليسرى' : 'Left index';
      case 'RI':
        return isArabic ? 'السبابة اليمنى' : 'Right index';
      case 'RM':
        return isArabic ? 'الوسطى اليمنى' : 'Right middle';
      case 'RR':
        return isArabic ? 'البنصر الأيمن' : 'Right ring';
      case 'RP':
        return isArabic ? 'الخنصر الأيمن' : 'Right pinky';
      default:
        return isArabic ? 'الإبهام' : 'Thumb';
    }
  }
}
