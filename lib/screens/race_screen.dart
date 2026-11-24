import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../data/curriculum.dart';
import '../game/speed_race.dart';
import '../state/app_state.dart';
import '../widgets/app_card.dart';

/// "Speed Race": type a sentence before the ghost does.
class RaceScreen extends StatefulWidget {
  const RaceScreen({super.key});

  @override
  State<RaceScreen> createState() => _RaceScreenState();
}

class _RaceScreenState extends State<RaceScreen> with SingleTickerProviderStateMixin {
  static const String _gameId = 'speed-race';

  late final Ticker _ticker;
  late final FocusNode _focus;
  late SpeedRace _race;
  final ValueNotifier<int> _frame = ValueNotifier<int>(0);
  Duration _last = Duration.zero;
  bool _saved = false;
  int _best = 0;

  SpeedRace _newRace(AppState state) {
    final texts = Curriculum.raceTexts();
    final text = texts[math.Random().nextInt(texts.length)];
    final ghost = (state.stats.averageWpm + 3).clamp(15.0, 70.0).toDouble();
    return SpeedRace(text: text, ghostWpm: ghost);
  }

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    _best = state.bestFor(_gameId);
    _race = _newRace(state);
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
    _race.update(math.min(dt, 0.1));
    _finishIfOver();
    _frame.value++;
  }

  void _finishIfOver() {
    if (!_race.isOver || _saved) {
      return;
    }
    _saved = true;
    _ticker.stop();
    final state = context.read<AppState>();
    if (state.settings.keySounds) {
      if (_race.won) {
        state.sounds.success();
      } else {
        state.sounds.error();
      }
    }
    if (_race.score > _best) {
      _best = _race.score;
      state.saveGameScore(_gameId, _race.score);
    }
  }

  void _restart() {
    final state = context.read<AppState>();
    setState(() {
      _race = _newRace(state);
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
    if (_race.isOver) {
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
    final ok = _race.handleChar(character);
    final state = context.read<AppState>();
    if (state.settings.keySounds) {
      if (ok) {
        state.sounds.click();
      } else {
        state.sounds.error();
      }
    }
    _finishIfOver();
    _frame.value++;
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppState>().l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(t.raceName)),
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
              final race = _race;
              final length = race.text.length;
              final mine = length == 0 ? 0.0 : race.typed / length;
              final ghost = length == 0 ? 0.0 : math.min(1.0, race.ghostChars / length);
              final caret = race.typed < length ? race.typed : -1;
              return Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Text('${t.gameScore}: ${race.score}', style: theme.textTheme.titleMedium),
                        const SizedBox(width: 24),
                        Text('${t.mistakesLabel}: ${race.mistakes}', style: theme.textTheme.titleMedium),
                        const Spacer(),
                        Text('${t.gameBestScore}: ${math.max(_best, race.score)}', style: theme.textTheme.titleMedium),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _Lane(label: t.youLabel, value: mine, color: scheme.primary, icon: Icons.directions_run_rounded),
                    const SizedBox(height: 8),
                    _Lane(label: t.ghostLabel, value: ghost, color: scheme.outline, icon: Icons.blur_on_rounded),
                    const SizedBox(height: 16),
                    Expanded(
                      child: AppCard(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: race.isOver
                                ? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        race.won ? t.raceWon : t.raceLost,
                                        style: theme.textTheme.headlineSmall,
                                      ),
                                      const SizedBox(height: 8),
                                      Text('${t.gameScore}: ${race.score}', style: theme.textTheme.titleLarge),
                                      const SizedBox(height: 16),
                                      FilledButton.icon(
                                        onPressed: _restart,
                                        icon: const Icon(Icons.replay_rounded),
                                        label: Text(t.playAgain),
                                      ),
                                    ],
                                  )
                                : SingleChildScrollView(
                                    child: Directionality(
                                      textDirection: TextDirection.ltr,
                                      child: Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: race.text.substring(0, race.typed),
                                              style: const TextStyle(color: AppTheme.success),
                                            ),
                                            if (caret >= 0)
                                              TextSpan(
                                                text: race.text[caret],
                                                style: TextStyle(
                                                  backgroundColor: scheme.primaryContainer,
                                                  color: scheme.onPrimaryContainer,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            TextSpan(
                                              text: caret >= 0 ? race.text.substring(caret + 1) : '',
                                              style: TextStyle(color: scheme.onSurface.withOpacity(0.55)),
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 28,
                                          height: 1.6,
                                          letterSpacing: 1,
                                          fontFamily: AppTheme.monoFamily,
                                          fontFamilyFallback: AppTheme.monoFallback,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    if (!race.started && !race.isOver)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(t.typeToBegin, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
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

class _Lane extends StatelessWidget {
  const _Lane({required this.label, required this.value, required this.color, required this.icon});

  final String label;
  final double value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 72, child: Text(label, style: Theme.of(context).textTheme.titleSmall)),
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(value: value, minHeight: 14, color: color),
          ),
        ),
      ],
    );
  }
}
