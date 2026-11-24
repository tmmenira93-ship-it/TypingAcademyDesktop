import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../game/word_sprint.dart';
import '../state/app_state.dart';
import '../widgets/app_card.dart';

/// "Word Sprint": as many words as possible in 60 seconds.
class SprintScreen extends StatefulWidget {
  const SprintScreen({super.key});

  @override
  State<SprintScreen> createState() => _SprintScreenState();
}

class _SprintScreenState extends State<SprintScreen> with SingleTickerProviderStateMixin {
  static const String _gameId = 'word-sprint';

  late final Ticker _ticker;
  late final FocusNode _focus;
  late WordSprint _game;
  final ValueNotifier<int> _frame = ValueNotifier<int>(0);
  Duration _last = Duration.zero;
  bool _saved = false;
  int _best = 0;

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    _best = state.bestFor(_gameId);
    _game = WordSprint(words: state.gameWords());
    _focus = FocusNode();
    _ticker = createTicker(_tick)..start();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focus.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _focus.dispose();
    _frame.dispose();
    super.dispose();
  }

  void _tick(Duration elapsed) {
    final dt = (elapsed - _last).inMicroseconds / 1000000.0;
    _last = elapsed;
    _game.update(math.min(dt, 0.1));
    if (_game.isOver && !_saved) {
      _saved = true;
      _ticker.stop();
      final state = context.read<AppState>();
      if (state.settings.keySounds) {
        state.sounds.success();
      }
      if (_game.score > _best) {
        _best = _game.score;
        state.saveGameScore(_gameId, _game.score);
      }
    }
    _frame.value++;
  }

  void _restart() {
    final state = context.read<AppState>();
    setState(() {
      _game = WordSprint(words: state.gameWords());
      _saved = false;
      _last = Duration.zero;
    });
    _ticker.stop();
    _ticker.start();
    _focus.requestFocus();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.of(context).maybePop();
      return KeyEventResult.handled;
    }
    if (_game.isOver) {
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        _restart();
      }
      return KeyEventResult.handled;
    }
    final keyboard = HardwareKeyboard.instance;
    if (keyboard.isMetaPressed || (keyboard.isControlPressed && !keyboard.isAltPressed)) {
      return KeyEventResult.ignored;
    }
    final character = event.character;
    if (character == null || character.isEmpty) {
      return KeyEventResult.ignored;
    }
    if (character.codeUnitAt(0) < 0x20) {
      return KeyEventResult.handled;
    }
    final ok = _game.handleChar(character);
    final state = context.read<AppState>();
    if (state.settings.keySounds) {
      if (ok) {
        state.sounds.click();
      } else {
        state.sounds.error();
      }
    }
    _frame.value++;
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppState>().l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(t.sprintName)),
      body: Focus(
        focusNode: _focus,
        autofocus: true,
        onKeyEvent: _onKey,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _focus.requestFocus(),
          child: ValueListenableBuilder<int>(
            valueListenable: _frame,
            builder: (context, _, __) {
              final game = _game;
              final typed = game.current.substring(0, game.position);
              final rest = game.current.substring(game.position);
              return Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Text('${t.timeLeft}: ${game.remaining.ceil()}', style: theme.textTheme.titleLarge),
                        const SizedBox(width: 24),
                        Text('${t.gameScore}: ${game.score}', style: theme.textTheme.titleMedium),
                        const SizedBox(width: 24),
                        Text('${t.wordsLabel}: ${game.completed}', style: theme.textTheme.titleMedium),
                        const SizedBox(width: 24),
                        Text('${t.mistakesLabel}: ${game.mistakes}', style: theme.textTheme.titleMedium),
                        const Spacer(),
                        Text('${t.gameBestScore}: ${math.max(_best, game.score)}', style: theme.textTheme.titleMedium),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(value: game.remaining / game.durationSeconds, minHeight: 10),
                    ),
                    Expanded(
                      child: Center(
                        child: game.isOver
                            ? AppCard(
                                child: Padding(
                                  padding: const EdgeInsets.all(28),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(t.gameOver, style: theme.textTheme.headlineSmall),
                                      const SizedBox(height: 8),
                                      Text('${t.gameScore}: ${game.score}', style: theme.textTheme.titleLarge),
                                      Text('${t.wordsLabel}: ${game.completed}'),
                                      const SizedBox(height: 16),
                                      FilledButton.icon(
                                        onPressed: _restart,
                                        icon: const Icon(Icons.replay_rounded),
                                        label: Text(t.playAgain),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Directionality(
                                textDirection: TextDirection.ltr,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(text: typed, style: const TextStyle(color: AppTheme.success)),
                                          TextSpan(text: rest, style: TextStyle(color: scheme.onSurface)),
                                        ],
                                      ),
                                      style: const TextStyle(
                                        fontSize: 64,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 2,
                                        fontFamily: AppTheme.monoFamily,
                                        fontFamilyFallback: AppTheme.monoFallback,
                                      ),
                                    ),
                                    if (!game.started) ...[
                                      const SizedBox(height: 16),
                                      Text(t.typeToBegin, style: theme.textTheme.bodyLarge),
                                    ],
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
