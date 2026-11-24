import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/l10n.dart';
import '../engine/typing_engine.dart';
import '../models/lesson.dart';
import '../services/sound_service.dart';
import '../services/speech_service.dart';
import '../state/app_state.dart';
import '../widgets/hands_guide.dart';
import '../widgets/keyboard_guide.dart';
import '../widgets/stat_pill.dart';
import '../widgets/typing_text_view.dart';
import 'results_screen.dart';
import '../widgets/app_card.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key, required this.lesson});

  final Lesson lesson;

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  late final TypingEngine engine;
  late final FocusNode focusNode;

  // Two tiny notifiers drive all live updates, so only the small parts that
  // changed are rebuilt (text, keyboard, stats) - never the whole screen.
  final ValueNotifier<int> _typing = ValueNotifier<int>(0); // key press / reset / pause
  final ValueNotifier<int> _clock = ValueNotifier<int>(0); // timer tick (time + WPM)

  Timer? _ticker;
  Timer? _errorFlash;
  bool _flashError = false;
  bool _finishing = false;
  DateTime? startedClock;
  late final bool _soundsOn;
  late final SoundService _sounds;
  late final SpeechService _speech;

  @override
  void initState() {
    super.initState();
    final lesson = widget.lesson;
    final app = context.read<AppState>();
    final settings = app.settings;
    _soundsOn = settings.keySounds;
    _sounds = app.sounds;
    _speech = app.speech;
    engine = TypingEngine(
      target: lesson.targetText,
      goalWpm: lesson.goalWpm,
      masteryAccuracy: lesson.masteryAccuracy,
      minWpm: lesson.minWpm,
      scored: lesson.isScored,
      // Key-introduction lessons always require the right key (TypingClub teaches each key that way).
      blockOnError: settings.blockOnError || lesson.type == LessonType.intro,
      allowBackspace: settings.allowBackspace,
    );
    if (settings.voiceOver) {
      _speech.speak(lesson.instructions(settings.languageCode == 'ar'));
    }
    focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _speech.stop();
    _ticker?.cancel();
    _errorFlash?.cancel();
    focusNode.dispose();
    _typing.dispose();
    _clock.dispose();
    super.dispose();
  }

  void _bump() {
    _typing.value++;
    _clock.value++;
  }

  void _startTicker() {
    // Started on the first key; before that there is nothing to refresh.
    _ticker ??= Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (engine.hasStarted && !engine.isPaused && !engine.isFinished) {
        _clock.value++;
      }
    });
  }

  void _flash() {
    _flashError = true;
    _errorFlash?.cancel();
    _errorFlash = Timer(const Duration(milliseconds: 160), () {
      _flashError = false;
      if (mounted) {
        _typing.value++;
      }
    });
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape) {
      Navigator.of(context).maybePop();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.backspace) {
      engine.backspace();
      _flashError = false;
      _bump();
      return KeyEventResult.handled;
    }
    final keyboard = HardwareKeyboard.instance;
    if (keyboard.isMetaPressed || (keyboard.isControlPressed && !keyboard.isAltPressed)) {
      return KeyEventResult.ignored; // keep OS / app shortcuts working
    }
    final character = event.character;
    if (character == null || character.isEmpty) {
      return KeyEventResult.ignored;
    }
    if (character.codeUnitAt(0) < 0x20) {
      return KeyEventResult.handled; // Enter, Tab, ... never count as typing
    }
    if (engine.isPaused || _finishing) {
      return KeyEventResult.handled;
    }
    startedClock ??= DateTime.now();
    final errorsBefore = engine.errorCount;
    engine.handleKey(character);
    _startTicker();
    final wrong = engine.errorCount > errorsBefore;
    if (_soundsOn) {
      if (wrong) {
        _sounds.error();
      } else {
        _sounds.click();
      }
    }
    if (wrong) {
      _flash();
    }
    _bump();
    if (engine.isFinished) {
      _finish();
    }
    return KeyEventResult.handled;
  }

  Future<void> _finish() async {
    if (_finishing) {
      return;
    }
    _finishing = true;
    _ticker?.cancel();
    final result = engine.result();
    if (_soundsOn && result.completed) {
      _sounds.success();
    }
    final replay = engine.replayData();
    final state = context.read<AppState>();
    final previousBest = state.progress[widget.lesson.id]?.bestWpm;
    final now = DateTime.now();
    await state.saveResult(
      lesson: widget.lesson,
      result: result,
      startedAt: startedClock ?? now.subtract(result.duration),
      finishedAt: now,
      keyAttempts: engine.keyAttempts,
      keyErrors: engine.keyErrors,
      replay: replay,
    );
    if (!mounted) {
      return;
    }
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ResultsScreen(
          lesson: widget.lesson,
          result: result,
          replay: replay,
          previousBestWpm: previousBest,
        ),
      ),
    );
  }

  void _togglePause() {
    if (engine.isPaused) {
      engine.resume();
    } else {
      engine.pause();
    }
    _bump();
  }

  void _retry() {
    engine.reset();
    startedClock = null;
    _flashError = false;
    _ticker?.cancel();
    _ticker = null;
    _bump();
  }

  String? _nextChar() {
    if (engine.isFinished || engine.typedLength >= engine.target.length) {
      return null;
    }
    return engine.target[engine.typedLength];
  }

  @override
  Widget build(BuildContext context) {
    final code = context.select<AppState, String>((s) => s.settings.languageCode);
    final t = S(code);
    final arabic = code == 'ar';
    final showKeyboard = context.select<AppState, bool>((s) => s.settings.showKeyboard);
    final showHands = context.select<AppState, bool>((s) => s.settings.showHands);
    final showLive = context.select<AppState, bool>((s) => s.settings.showLiveStats);
    final theme = Theme.of(context);
    final lesson = widget.lesson;
    final textLength = lesson.targetText.length;
    final fontSize = textLength <= 70 ? 30.0 : (textLength <= 105 ? 26.0 : 23.0);

    return Scaffold(
      appBar: AppBar(
        title: Text(lesson.order > 0 ? '${lesson.order}. ${lesson.title(arabic)}' : lesson.title(arabic)),
      ),
      body: Focus(
        focusNode: focusNode,
        autofocus: true,
        onKeyEvent: _onKey,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => focusNode.requestFocus(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 28, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  lesson.instructions(arabic),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 12),
                ValueListenableBuilder<int>(
                  valueListenable: _typing,
                  builder: (_, __, ___) {
                    final total = engine.target.length;
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: total == 0 ? 0 : engine.typedLength / total,
                        minHeight: 8,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                ValueListenableBuilder<int>(
                  valueListenable: _clock,
                  builder: (_, __, ___) => _buildStats(t, showLive),
                ),
                const SizedBox(height: 12),
                Expanded(
                  flex: 4,
                  child: AppCard(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: SingleChildScrollView(
                          child: ValueListenableBuilder<int>(
                            valueListenable: _typing,
                            builder: (_, __, ___) => TypingTextView(engine: engine, fontSize: fontSize),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<int>(
                  valueListenable: _typing,
                  builder: (_, __, ___) => _buildHint(theme, t),
                ),
                if (showKeyboard)
                  Expanded(
                    flex: 5,
                    child: LayoutBuilder(
                      builder: (context, box) {
                        // The hands only appear when the window is tall enough to keep the keys large.
                        final hands = showHands && box.maxHeight >= 340;
                        return Column(
                          children: [
                            Expanded(
                              child: ValueListenableBuilder<int>(
                                valueListenable: _typing,
                                builder: (_, __, ___) => KeyboardGuide(target: _nextChar(), error: _flashError),
                              ),
                            ),
                            if (hands)
                              SizedBox(
                                height: 96,
                                child: ValueListenableBuilder<int>(
                                  valueListenable: _typing,
                                  builder: (_, __, ___) {
                                    final next = _nextChar();
                                    return HandsGuide(finger: next == null ? null : KeyboardGuide.fingerFor(next));
                                  },
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 8),
                // ExcludeFocus: clicking a button must not steal the keyboard from the typing area.
                ExcludeFocus(
                  child: ValueListenableBuilder<int>(
                    valueListenable: _typing,
                    builder: (_, __, ___) => Row(
                      children: [
                        FilledButton.tonalIcon(
                          onPressed: engine.hasStarted && !engine.isFinished ? _togglePause : null,
                          icon: Icon(engine.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded),
                          label: Text(engine.isPaused ? t.resume : t.pause),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: _retry,
                          icon: const Icon(Icons.replay_rounded),
                          label: Text(t.retry),
                        ),
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          child: Text(t.finish),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStats(S t, bool showLive) {
    final label = engine.isPaused ? '${t.time} · ${t.paused}' : t.time;
    final pills = <Widget>[
      if (showLive) StatPill(label: t.wpm, value: engine.liveWpm.toStringAsFixed(0)),
      if (showLive) StatPill(label: t.accuracy, value: '${engine.liveAccuracy.toStringAsFixed(0)}%'),
      StatPill(label: t.errors, value: '${engine.errorCount}'),
      StatPill(label: label, value: _format(engine.elapsed())),
    ];
    return Row(
      children: [
        for (var i = 0; i < pills.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(child: pills[i]),
        ],
      ],
    );
  }

  Widget _buildHint(ThemeData theme, S t) {
    final next = _nextChar();
    final finger = next == null ? null : KeyboardGuide.fingerFor(next);
    final parts = <String>[
      if (!engine.hasStarted) t.typeToBegin,
      if (finger != null) '${t.fingerHint}: ${t.fingerName(finger)}',
    ];
    return SizedBox(
      height: 28,
      child: Center(
        child: Text(
          parts.join('   •   '),
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
        ),
      ),
    );
  }

  String _format(Duration value) {
    final seconds = value.inSeconds;
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
