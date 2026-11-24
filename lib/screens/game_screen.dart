import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../game/word_rain.dart';
import '../state/app_state.dart';
import '../widgets/app_card.dart';

enum GameMode { words, letters }

/// "Word Rain" (falling words) and "Letter Pop" (falling letters).
class GameScreen extends StatefulWidget {
  const GameScreen({super.key, this.mode = GameMode.words});

  final GameMode mode;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  late final FocusNode _focus;
  late WordRainGame _game;
  final ValueNotifier<int> _frame = ValueNotifier<int>(0);
  Duration _last = Duration.zero;
  bool _saved = false;
  int _best = 0;

  String get _gameId => widget.mode == GameMode.words ? 'word-rain' : 'letter-pop';

  WordRainGame _newGame(AppState state) {
    return widget.mode == GameMode.words
        ? WordRainGame(words: state.gameWords())
        : WordRainGame(words: state.gameLetters(), speed: 1.15);
  }

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    _best = state.bestFor(_gameId);
    _game = _newGame(state);
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
    final livesBefore = _game.lives;
    _game.update(math.min(dt, 0.1));
    final state = context.read<AppState>();
    if (state.settings.keySounds && _game.lives < livesBefore) {
      state.sounds.error();
    }
    if (_game.isOver && !_saved) {
      _saved = true;
      _ticker.stop();
      if (_game.score > _best) {
        _best = _game.score;
        if (widget.mode == GameMode.words) {
          state.saveGameBest(_game.score);
        } else {
          state.saveGameScore(_gameId, _game.score);
        }
      }
    }
    _frame.value++;
  }

  void _restart() {
    final state = context.read<AppState>();
    setState(() {
      _game = _newGame(state);
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

    return Scaffold(
      appBar: AppBar(title: Text(widget.mode == GameMode.words ? t.gameName : t.letterPopName)),
      body: Focus(
        focusNode: _focus,
        autofocus: true,
        onKeyEvent: _onKey,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _focus.requestFocus(),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: ValueListenableBuilder<int>(
              valueListenable: _frame,
              builder: (context, _, __) {
                final game = _game;
                return LayoutBuilder(
                  builder: (context, box) {
                    final fall = math.max(0.0, box.maxHeight - 64);
                    return Stack(
                      children: [
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(height: 6, color: AppTheme.danger.withOpacity(0.6)),
                        ),
                        for (final word in game.active)
                          Positioned(
                            left: word.x * box.maxWidth,
                            top: 48 + word.y * fall,
                            child: _WordChip(
                              word: word,
                              isTarget: identical(word, game.target),
                              fontSize: widget.mode == GameMode.words ? 24 : 32,
                            ),
                          ),
                        Positioned(
                          left: 16,
                          right: 16,
                          top: 8,
                          child: Row(
                            children: [
                              Text('${t.gameScore}: ${game.score}', style: theme.textTheme.titleMedium),
                              const SizedBox(width: 24),
                              Text('${t.gameLevel}: ${game.level}', style: theme.textTheme.titleMedium),
                              const SizedBox(width: 24),
                              Text('${t.gameBestScore}: ${math.max(_best, game.score)}', style: theme.textTheme.titleMedium),
                              const Spacer(),
                              for (var i = 0; i < 3; i++)
                                Icon(
                                  i < game.lives ? Icons.favorite : Icons.favorite_border,
                                  color: AppTheme.danger,
                                ),
                            ],
                          ),
                        ),
                        if (game.isOver)
                          Center(
                            child: AppCard(
                              child: Padding(
                                padding: const EdgeInsets.all(28),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(t.gameOver, style: theme.textTheme.headlineSmall),
                                    const SizedBox(height: 8),
                                    Text('${t.gameScore}: ${game.score}', style: theme.textTheme.titleLarge),
                                    const SizedBox(height: 16),
                                    FilledButton.icon(
                                      onPressed: _restart,
                                      icon: const Icon(Icons.replay_rounded),
                                      label: Text(t.playAgain),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _WordChip extends StatelessWidget {
  const _WordChip({required this.word, required this.isTarget, required this.fontSize});

  final FallingWord word;
  final bool isTarget;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final typed = word.text.substring(0, word.typed);
    final rest = word.text.substring(word.typed);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isTarget ? scheme.primaryContainer : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: isTarget ? Border.all(color: scheme.primary, width: 2) : null,
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: typed, style: const TextStyle(color: AppTheme.success)),
            TextSpan(text: rest, style: TextStyle(color: scheme.onSurface)),
          ],
        ),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          fontFamily: AppTheme.monoFamily,
          fontFamilyFallback: AppTheme.monoFallback,
        ),
      ),
    );
  }
}
