import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../game/key_hunt.dart';
import '../state/app_state.dart';
import '../widgets/keyboard_guide.dart';
import '../widgets/app_card.dart';

/// "Key Hunt": find the key on the keyboard and press it.
class HuntScreen extends StatefulWidget {
  const HuntScreen({super.key});

  @override
  State<HuntScreen> createState() => _HuntScreenState();
}

class _HuntScreenState extends State<HuntScreen> with SingleTickerProviderStateMixin {
  static const String _gameId = 'key-hunt';

  late final Ticker _ticker;
  late final FocusNode _focus;
  late KeyHunt _game;
  final ValueNotifier<int> _frame = ValueNotifier<int>(0);
  Timer? _flashTimer;
  Duration _last = Duration.zero;
  bool _saved = false;
  bool _flash = false;
  int _best = 0;

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    _best = state.bestFor(_gameId);
    _game = KeyHunt(keys: state.huntKeys());
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
    _flashTimer?.cancel();
    _ticker.dispose();
    _focus.dispose();
    _frame.dispose();
    super.dispose();
  }

  void _tick(Duration elapsed) {
    final dt = (elapsed - _last).inMicroseconds / 1000000.0;
    _last = elapsed;
    final missesBefore = _game.misses;
    _game.update(math.min(dt, 0.1));
    final state = context.read<AppState>();
    if (state.settings.keySounds && _game.misses > missesBefore) {
      state.sounds.error();
    }
    if (_game.isOver && !_saved) {
      _saved = true;
      _ticker.stop();
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
      _game = KeyHunt(keys: state.huntKeys());
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
    if (!ok) {
      _flash = true;
      _flashTimer?.cancel();
      _flashTimer = Timer(const Duration(milliseconds: 180), () {
        _flash = false;
        if (mounted) {
          _frame.value++;
        }
      });
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
      appBar: AppBar(title: Text(t.huntName)),
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
              final shown = game.current.toUpperCase();
              final finger = KeyboardGuide.fingerFor(game.current);
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
                        Text('${t.streakLabel}: ${game.streak}', style: theme.textTheme.titleMedium),
                        const SizedBox(width: 24),
                        Text('${t.mistakesLabel}: ${game.misses}', style: theme.textTheme.titleMedium),
                        const Spacer(),
                        Text('${t.gameBestScore}: ${math.max(_best, game.score)}', style: theme.textTheme.titleMedium),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(value: game.remaining / game.durationSeconds, minHeight: 10),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      flex: 3,
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
                                      Text('${t.streakLabel}: ${game.bestStreak}'),
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
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 120,
                                    height: 120,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: scheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: _flash ? AppTheme.danger : scheme.primary,
                                        width: _flash ? 5 : 2,
                                      ),
                                    ),
                                    child: Text(
                                      shown,
                                      style: TextStyle(
                                        fontSize: 64,
                                        fontWeight: FontWeight.w800,
                                        color: scheme.onPrimaryContainer,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: 220,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: LinearProgressIndicator(
                                        value: (game.keyTimeLeft / game.perKeySeconds).clamp(0.0, 1.0).toDouble(),
                                        minHeight: 8,
                                        color: AppTheme.accent,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    height: 24,
                                    child: Text(
                                      !game.started
                                          ? t.typeToBegin
                                          : (game.hinted && finger != null ? '${t.fingerHint}: ${t.fingerName(finger)}' : ''),
                                      style: theme.textTheme.bodyLarge,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: KeyboardGuide(target: game.hinted && !game.isOver ? game.current : null, error: _flash),
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
