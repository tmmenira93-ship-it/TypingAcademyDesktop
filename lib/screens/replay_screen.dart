import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../engine/typing_engine.dart';
import '../state/app_state.dart';
import '../widgets/stat_pill.dart';
import '../widgets/typing_text_view.dart';
import '../widgets/app_card.dart';

/// Plays a finished attempt back key by key, at the original rhythm.
class ReplayScreen extends StatefulWidget {
  const ReplayScreen({super.key, required this.data, required this.title});

  final ReplayData data;
  final String title;

  @override
  State<ReplayScreen> createState() => _ReplayScreenState();
}

class _ReplayScreenState extends State<ReplayScreen> {
  static final DateTime _base = DateTime(2000);

  late TypingEngine engine;
  final ValueNotifier<int> _frame = ValueNotifier<int>(0);
  Timer? _timer;
  int _virtualMs = 0;
  int _index = 0;
  double _t = 0;
  double _speed = 1;
  bool _playing = true;

  @override
  void initState() {
    super.initState();
    _reset();
    _start();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _frame.dispose();
    super.dispose();
  }

  void _reset() {
    _virtualMs = 0;
    _index = 0;
    _t = 0;
    engine = TypingEngine(
      target: widget.data.target,
      blockOnError: widget.data.blockOnError,
      allowBackspace: widget.data.allowBackspace,
      clock: () => _base.add(Duration(milliseconds: _virtualMs)),
    );
  }

  void _start() {
    _timer?.cancel();
    _playing = true;
    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) => _step());
  }

  void _step() {
    if (!_playing) {
      return;
    }
    _t += 16 * _speed;
    final log = widget.data.log;
    while (_index < log.length && log[_index].ms <= _t) {
      final entry = log[_index];
      _virtualMs = entry.ms;
      if (entry.key == KeyLogEntry.backspaceKey) {
        engine.backspace();
      } else {
        engine.handleKey(entry.key);
      }
      _index += 1;
    }
    if (_index >= log.length) {
      _virtualMs = log.isEmpty ? 0 : log.last.ms;
      _playing = false;
      _timer?.cancel();
      if (mounted) {
        setState(() {});
      }
    } else {
      _virtualMs = _t.round();
    }
    _frame.value++;
  }

  void _togglePlay() {
    if (_playing) {
      _playing = false;
      _timer?.cancel();
    } else if (_index >= widget.data.log.length) {
      _reset();
      _start();
    } else {
      _start();
    }
    setState(() {});
  }

  void _restart() {
    _reset();
    _start();
    _frame.value++;
    setState(() {});
  }

  String _format(Duration value) {
    final seconds = value.inSeconds;
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppState>().l10n;
    final theme = Theme.of(context);
    final total = widget.data.durationMs;
    final length = widget.data.target.length;
    final fontSize = length <= 70 ? 30.0 : (length <= 105 ? 26.0 : 23.0);

    return Scaffold(
      appBar: AppBar(title: Text(t.replayTitle)),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            ValueListenableBuilder<int>(
              valueListenable: _frame,
              builder: (_, __, ___) {
                final progress = total == 0 ? 1.0 : (_t / total).clamp(0.0, 1.0).toDouble();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(value: progress, minHeight: 8),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: StatPill(label: t.wpm, value: engine.liveWpm.toStringAsFixed(0))),
                        const SizedBox(width: 10),
                        Expanded(child: StatPill(label: t.accuracy, value: '${engine.liveAccuracy.toStringAsFixed(0)}%')),
                        const SizedBox(width: 10),
                        Expanded(child: StatPill(label: t.errors, value: '${engine.errorCount}')),
                        const SizedBox(width: 10),
                        Expanded(child: StatPill(label: t.time, value: _format(engine.elapsed()))),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: SingleChildScrollView(
                      child: ValueListenableBuilder<int>(
                        valueListenable: _frame,
                        builder: (_, __, ___) => TypingTextView(engine: engine, fontSize: fontSize),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilledButton.tonalIcon(
                  onPressed: _togglePlay,
                  icon: Icon(_playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
                  label: Text(_playing ? t.pause : t.resume),
                ),
                OutlinedButton.icon(
                  onPressed: _restart,
                  icon: const Icon(Icons.replay_rounded),
                  label: Text(t.retry),
                ),
                SegmentedButton<double>(
                  segments: const [
                    ButtonSegment<double>(value: 1, label: Text('1x')),
                    ButtonSegment<double>(value: 2, label: Text('2x')),
                    ButtonSegment<double>(value: 4, label: Text('4x')),
                  ],
                  selected: {_speed},
                  onSelectionChanged: (value) => setState(() => _speed = value.first),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
