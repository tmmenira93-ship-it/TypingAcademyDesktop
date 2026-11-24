import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../game/magic_tiles.dart';
import '../state/app_state.dart';
import '../widgets/app_card.dart';

/// "Magic Tiles": press D, F, J or K as the tiles reach the bottom and play the song.
class MagicTilesScreen extends StatefulWidget {
  const MagicTilesScreen({super.key});

  @override
  State<MagicTilesScreen> createState() => _MagicTilesScreenState();
}

class _MagicTilesScreenState extends State<MagicTilesScreen> with SingleTickerProviderStateMixin {
  static const String _gameId = 'magic-tiles';
  static const List<String> _keys = ['d', 'f', 'j', 'k'];

  late final Ticker _ticker;
  late final FocusNode _focus;
  late MagicTiles _game;
  final ValueNotifier<int> _frame = ValueNotifier<int>(0);
  final List<double> _flash = <double>[0, 0, 0, 0];
  Duration _last = Duration.zero;
  bool _saved = false;
  bool _sound = true;
  int _best = 0;
  int _songIndex = math.Random().nextInt(MagicTiles.songs.length);

  MagicTiles _newGame() {
    final melody = MagicTiles.songs[_songIndex % MagicTiles.songs.length];
    _songIndex += 1;
    return MagicTiles(laneKeys: _keys, melody: melody);
  }

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    _best = state.bestFor(_gameId);
    _game = _newGame();
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
    final dt = math.min((elapsed - _last).inMicroseconds / 1000000.0, 0.1);
    _last = elapsed;
    for (var i = 0; i < _flash.length; i++) {
      _flash[i] = math.max(0.0, _flash[i] - dt * 4);
    }
    final livesBefore = _game.lives;
    _game.update(dt);
    if (_sound && _game.lives < livesBefore) {
      context.read<AppState>().sounds.error();
    }
    _checkOver();
    _frame.value++;
  }

  void _checkOver() {
    if (!_game.isOver || _saved) {
      return;
    }
    _saved = true;
    _ticker.stop();
    final state = context.read<AppState>();
    if (_game.score > _best) {
      _best = _game.score;
      state.saveGameScore(_gameId, _game.score);
    }
    _frame.value++;
  }

  void _press(int lane) {
    if (_game.isOver) {
      return;
    }
    final livesBefore = _game.lives;
    final tile = _game.press(lane);
    _flash[lane] = 1.0;
    final sounds = context.read<AppState>().sounds;
    if (tile != null) {
      if (_sound) {
        sounds.note(tile.note);
      }
    } else if (_sound && _game.lives < livesBefore) {
      sounds.error();
    }
    _checkOver();
    _frame.value++;
  }

  void _restart() {
    setState(() {
      _game = _newGame();
      _saved = false;
      _last = Duration.zero;
    });
    _ticker.stop();
    _ticker.start();
    _focus.requestFocus();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
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
    final lane = _keys.indexOf(character.toLowerCase());
    if (lane >= 0) {
      _press(lane);
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppState>().l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.magicTilesName),
        actions: [
          IconButton(
            tooltip: t.keySoundsLabel,
            icon: Icon(_sound ? Icons.volume_up_rounded : Icons.volume_off_rounded),
            onPressed: () => setState(() => _sound = !_sound),
          ),
        ],
      ),
      body: Focus(
        focusNode: _focus,
        autofocus: true,
        onKeyEvent: _onKey,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Column(
              children: [
                ValueListenableBuilder<int>(
                  valueListenable: _frame,
                  builder: (context, _, __) {
                    final game = _game;
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Row(
                        children: [
                          Text('${t.gameScore}: ${game.score}', style: theme.textTheme.titleMedium),
                          const SizedBox(width: 16),
                          Text('${t.streakLabel}: ${game.combo}', style: theme.textTheme.titleMedium),
                          const SizedBox(width: 16),
                          Text('${t.gameLevel}: ${game.level}', style: theme.textTheme.titleMedium),
                          const Spacer(),
                          for (var i = 0; i < 3; i++)
                            Icon(i < game.lives ? Icons.favorite : Icons.favorite_border, color: AppTheme.danger, size: 22),
                        ],
                      ),
                    );
                  },
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, box) {
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapDown: (details) {
                          _focus.requestFocus();
                          final lane = (details.localPosition.dx / box.maxWidth * _keys.length).floor();
                          _press(lane.clamp(0, _keys.length - 1).toInt());
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CustomPaint(
                                painter: _TilesPainter(
                                  game: _game,
                                  flashes: _flash,
                                  keys: _keys,
                                  repaint: _frame,
                                ),
                              ),
                              ValueListenableBuilder<int>(
                                valueListenable: _frame,
                                builder: (context, _, __) {
                                  final game = _game;
                                  if (game.isOver) {
                                    return Center(
                                      child: AppCard(
                                        child: Padding(
                                          padding: const EdgeInsets.all(24),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(t.gameOver, style: theme.textTheme.headlineSmall),
                                              const SizedBox(height: 8),
                                              Text('${t.gameScore}: ${game.score}', style: theme.textTheme.titleLarge),
                                              Text('${t.gameBestScore}: ${math.max(_best, game.score)}'),
                                              Text('${t.streakLabel}: ${game.bestCombo}'),
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
                                    );
                                  }
                                  if (!game.started) {
                                    return Align(
                                      alignment: const Alignment(0, -0.6),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: Text(
                                          t.tilesHint,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(color: Colors.white, fontSize: 16),
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TilesPainter extends CustomPainter {
  _TilesPainter({
    required this.game,
    required this.flashes,
    required this.keys,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final MagicTiles game;
  final List<double> flashes;
  final List<String> keys;

  static const double _keyRow = 56;

  @override
  void paint(Canvas canvas, Size size) {
    final playHeight = size.height - _keyRow;
    if (playHeight <= 0) {
      return;
    }
    final laneWidth = size.width / keys.length;
    final whole = Offset.zero & size;
    canvas.drawRect(
      whole,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F172A), Color(0xFF312E81)],
        ).createShader(whole),
    );

    final separator = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;
    for (var i = 0; i < keys.length; i++) {
      if (flashes[i] > 0) {
        canvas.drawRect(
          Rect.fromLTWH(i * laneWidth, 0, laneWidth, playHeight),
          Paint()..color = Colors.white.withOpacity(0.14 * flashes[i]),
        );
      }
      if (i > 0) {
        canvas.drawLine(Offset(i * laneWidth, 0), Offset(i * laneWidth, playHeight), separator);
      }
    }
    canvas.drawLine(
      Offset(0, playHeight * 0.9),
      Offset(size.width, playHeight * 0.9),
      Paint()
        ..color = const Color(0x88FBBF24)
        ..strokeWidth = 2,
    );

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, playHeight));
    for (final tile in game.tiles) {
      final rect = Rect.fromLTWH(
        tile.lane * laneWidth + 4,
        tile.y * playHeight,
        laneWidth - 8,
        MagicTiles.tileHeight * playHeight,
      );
      final rounded = RRect.fromRectAndRadius(rect, const Radius.circular(12));
      if (tile.hit) {
        canvas.drawRRect(rounded, Paint()..color = const Color(0xFF34D399).withOpacity(0.35));
      } else {
        canvas.drawRRect(
          rounded,
          Paint()
            ..shader = const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
            ).createShader(rect),
        );
        _label(canvas, keys[tile.lane].toUpperCase(), rect.center, 28, Colors.white);
      }
    }
    canvas.restore();

    for (var i = 0; i < keys.length; i++) {
      final cap = RRect.fromRectAndRadius(
        Rect.fromLTWH(i * laneWidth + 6, playHeight + 8, laneWidth - 12, _keyRow - 16),
        const Radius.circular(10),
      );
      canvas.drawRRect(cap, Paint()..color = Colors.white.withOpacity(0.10 + 0.35 * flashes[i]));
      _label(canvas, keys[i].toUpperCase(), cap.outerRect.center, 22, Colors.white);
    }
  }

  static void _label(Canvas canvas, String text, Offset center, double fontSize, Color color) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w800, color: color),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, center - Offset(painter.width / 2, painter.height / 2));
    painter.dispose();
  }

  @override
  bool shouldRepaint(_TilesPainter old) => old.game != game;
}
