import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../data/lesson_catalog.dart';
import '../engine/typing_engine.dart';
import '../models/lesson.dart';
import '../state/app_state.dart';
import '../widgets/app_card.dart';
import '../widgets/app_shell.dart';
import '../widgets/star_burst.dart';
import '../widgets/stat_card.dart';
import 'practice_screen.dart';
import 'replay_screen.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({
    super.key,
    required this.lesson,
    required this.result,
    this.replay,
    this.previousBestWpm,
  });

  final Lesson lesson;
  final TypingResult result;

  /// The key presses of this attempt (null = no playback available).
  final ReplayData? replay;

  /// Best speed on this lesson before this attempt (null = first attempt).
  final double? previousBestWpm;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final next = LessonCatalog.nextAfter(lesson.id);
    final scored = lesson.isScored;
    final passed = result.completed;
    final canNext = next != null && state.isUnlocked(next);
    final isBest = scored && passed && previousBestWpm != null && previousBestWpm! > 0 && result.wpm > previousBestWpm!;
    final good = !scored || passed;
    final accent = good ? AppTheme.success : AppTheme.accent;
    final subtitle = !scored ? t.introDone : (passed ? t.encouragement : t.tryAccuracy);

    void go(Lesson target) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => PracticeScreen(lesson: target)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(t.resultsTitle)),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 780),
          child: ListView(
            padding: const EdgeInsets.all(28),
            children: [
              AppCard(
                color: accent.withOpacity(0.10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                  child: Column(
                    children: [
                      Icon(good ? Icons.emoji_events_rounded : Icons.replay_circle_filled_rounded, size: 52, color: accent),
                      const SizedBox(height: 10),
                      Text(
                        good ? t.resultComplete : t.resultTryAgain,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lesson.title(state.isArabic),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                      if (scored) ...[
                        const SizedBox(height: 16),
                        StarBurst(count: result.stars),
                      ],
                      if (isBest) ...[
                        const SizedBox(height: 14),
                        Chip(
                          avatar: const Icon(Icons.trending_up_rounded, size: 18),
                          label: Text(t.newBest),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Text(subtitle, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: 170,
                    child: StatCard(label: t.wpm, value: result.wpm.toStringAsFixed(1), icon: Icons.speed),
                  ),
                  SizedBox(
                    width: 170,
                    child: StatCard(
                      label: t.accuracy,
                      value: '${result.accuracy.toStringAsFixed(1)}%',
                      icon: Icons.verified,
                      color: AppTheme.success,
                    ),
                  ),
                  SizedBox(
                    width: 170,
                    child: StatCard(
                      label: t.errors,
                      value: '${result.errors}',
                      icon: Icons.error_outline,
                      color: AppTheme.danger,
                    ),
                  ),
                  SizedBox(
                    width: 170,
                    child: StatCard(
                      label: t.time,
                      value: _format(result.duration),
                      icon: Icons.timer_outlined,
                      color: AppTheme.accent,
                    ),
                  ),
                ],
              ),
              if (scored) ...[
                const SizedBox(height: 20),
                AppCard(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.requirements, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        _RequirementRow(
                          label: t.minAccuracyReq,
                          actual: '${result.accuracy.toStringAsFixed(1)}%',
                          needed: '${lesson.masteryAccuracy.toStringAsFixed(0)}%',
                          met: result.accuracy >= lesson.masteryAccuracy,
                        ),
                        if (lesson.minWpm > 0)
                          _RequirementRow(
                            label: t.minSpeedReq,
                            actual: result.wpm.toStringAsFixed(1),
                            needed: '${lesson.minWpm}',
                            met: result.wpm >= lesson.minWpm,
                          ),
                        _RequirementRow(
                          label: t.goalSpeedReq,
                          actual: result.wpm.toStringAsFixed(1),
                          needed: '${lesson.goalWpm}',
                          met: result.wpm >= lesson.goalWpm,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  if (canNext && passed)
                    FilledButton.icon(
                      onPressed: () => go(next),
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: Text(t.nextLesson),
                    ),
                  if (canNext && passed)
                    FilledButton.tonalIcon(
                      onPressed: () => go(lesson),
                      icon: const Icon(Icons.replay_rounded),
                      label: Text(t.retry),
                    )
                  else
                    FilledButton.icon(
                      onPressed: () => go(lesson),
                      icon: const Icon(Icons.replay_rounded),
                      label: Text(t.retry),
                    ),
                  if (replay != null)
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ReplayScreen(data: replay!, title: lesson.title(state.isArabic)),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_circle_outline),
                      label: Text(t.watchReplay),
                    ),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute<void>(builder: (_) => const AppShell(initialIndex: 1)),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.map_outlined),
                    label: Text(t.backToMap),
                  ),
                ],
              ),
            ],
          ),
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

class _RequirementRow extends StatelessWidget {
  const _RequirementRow({
    required this.label,
    required this.actual,
    required this.needed,
    required this.met,
  });

  final String label;
  final String actual;
  final String needed;
  final bool met;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        met ? Icons.check_circle_rounded : Icons.cancel_outlined,
        color: met ? AppTheme.success : AppTheme.danger,
      ),
      title: Text(label),
      trailing: Text(
        '$actual  /  $needed',
        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
