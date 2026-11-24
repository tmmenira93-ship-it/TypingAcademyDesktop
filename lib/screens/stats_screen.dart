import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../data/lesson_catalog.dart';
import '../models/key_stat.dart';
import '../state/app_state.dart';
import '../widgets/app_card.dart';
import '../widgets/keyboard_guide.dart';
import '../widgets/stat_card.dart';
import '../widgets/trend_chart.dart';
import 'replay_screen.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.l10n;
    final review = state.reviewLessons();
    final minutes = (state.stats.totalPracticeMs / 60000).toStringAsFixed(1);
    final keys = _keyRows(state.keyStats);
    final fingers = _fingerRows(state.keyStats);

    final theme = Theme.of(context);
    final chronological = state.recent.reversed.toList();
    final wpmValues = [for (final item in chronological) item.attempt.wpm];
    final accuracyValues = [for (final item in chronological) item.attempt.accuracy];

    Widget chart(String title, List<double> values, Color color, {double? maxY}) {
      return AppCard(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              if (values.isEmpty) Text(t.noRecent) else TrendChart(values: values, color: color, maxY: maxY),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(28),
      child: ListView(
        children: [
          Text(t.statistics, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(width: 240, child: StatCard(label: t.totalTime, value: '$minutes min', icon: Icons.timer_outlined, color: AppTheme.accent)),
              SizedBox(width: 240, child: StatCard(label: t.avgWpm, value: state.stats.averageWpm.toStringAsFixed(1), icon: Icons.speed)),
              SizedBox(width: 240, child: StatCard(label: t.avgAccuracy, value: '${state.stats.averageAccuracy.toStringAsFixed(1)}%', icon: Icons.verified, color: AppTheme.success)),
              SizedBox(width: 240, child: StatCard(label: t.attempts, value: '${state.stats.totalAttempts}', icon: Icons.replay)),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, box) {
              final speed = chart(t.speedTrend, wpmValues, theme.colorScheme.primary);
              final accuracy = chart(t.accuracyTrend, accuracyValues, AppTheme.success, maxY: 100);
              if (box.maxWidth >= 760) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: speed),
                    const SizedBox(width: 16),
                    Expanded(child: accuracy),
                  ],
                );
              }
              return Column(children: [speed, const SizedBox(height: 16), accuracy]);
            },
          ),
          const SizedBox(height: 20),
          _Panel(
            title: t.recentAttempts,
            children: [
              if (state.recent.isEmpty) Text(t.noRecent),
              for (final item in state.recent.take(10))
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    item.attempt.completed ? Icons.check_circle_outline : Icons.radio_button_unchecked,
                    color: item.attempt.completed ? AppTheme.success : null,
                  ),
                  title: Text(LessonCatalog.byId(item.attempt.lessonId)?.title(state.isArabic) ?? t.weakKeysTitle),
                  subtitle: Text(
                    '${item.attempt.wpm.toStringAsFixed(1)} ${t.wpm}  •  ${item.attempt.accuracy.toStringAsFixed(1)}%  •  '
                    '${item.attempt.finishedAt.toLocal().toString().substring(0, 16)}',
                  ),
                  trailing: item.hasReplay && item.attempt.id != null
                      ? IconButton(
                          tooltip: t.watchReplay,
                          icon: const Icon(Icons.play_circle_outline),
                          onPressed: () async {
                            final data = await state.replayFor(item.attempt.id!);
                            if (data != null && context.mounted) {
                              final title = LessonCatalog.byId(item.attempt.lessonId)?.title(state.isArabic) ?? t.weakKeysTitle;
                              await Navigator.of(context).push(
                                MaterialPageRoute<void>(builder: (_) => ReplayScreen(data: data, title: title)),
                              );
                            }
                          },
                        )
                      : null,
                ),
            ],
          ),
          const SizedBox(height: 16),
          _Panel(
            title: t.keysBreakdown,
            children: [
              if (keys.isEmpty) Text(t.noKeyData),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final item in keys)
                    Tooltip(
                      message: '${(item.accuracy * 100).toStringAsFixed(0)}%  (${item.attempts})',
                      child: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _accuracyColor(item.accuracy).withOpacity(0.25),
                          border: Border.all(color: _accuracyColor(item.accuracy)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(item.label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Panel(
            title: t.fingersBreakdown,
            children: [
              if (fingers.isEmpty) Text(t.noKeyData),
              for (final item in fingers)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(radius: 8, backgroundColor: FingerColors.map[item.code]),
                  title: Text(t.fingerName(item.code)),
                  subtitle: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(value: item.accuracy, minHeight: 8, color: _accuracyColor(item.accuracy)),
                  ),
                  trailing: Text('${(item.accuracy * 100).toStringAsFixed(0)}%'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _Panel(
            title: t.needsReview,
            children: [
              if (review.isEmpty) Text(t.none),
              for (final lesson in review)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.refresh),
                  title: Text(lesson.title(state.isArabic)),
                  subtitle: Text('${t.best}: ${state.progress[lesson.id]?.bestAccuracy.toStringAsFixed(1)}%'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _KeyRow {
  const _KeyRow(this.label, this.attempts, this.accuracy);

  final String label;
  final int attempts;
  final double accuracy;
}

class _FingerRow {
  const _FingerRow(this.code, this.accuracy);

  final String code;
  final double accuracy;
}

Color _accuracyColor(double accuracy) {
  if (accuracy >= 0.95) {
    return AppTheme.success;
  }
  if (accuracy >= 0.85) {
    return AppTheme.accent;
  }
  return AppTheme.danger;
}

List<_KeyRow> _keyRows(List<KeyStat> stats) {
  final rows = <_KeyRow>[];
  for (final item in stats) {
    if (item.char.trim().isEmpty || item.attempts < 3) {
      continue;
    }
    rows.add(_KeyRow(item.char, item.attempts, 1 - item.errorRate));
  }
  rows.sort((a, b) => a.accuracy.compareTo(b.accuracy));
  return rows;
}

List<_FingerRow> _fingerRows(List<KeyStat> stats) {
  const order = ['LP', 'LR', 'LM', 'LI', 'RI', 'RM', 'RR', 'RP', 'T'];
  final attempts = <String, int>{};
  final errors = <String, int>{};
  for (final item in stats) {
    final finger = KeyboardGuide.fingerFor(item.char);
    if (finger == null) {
      continue;
    }
    attempts[finger] = (attempts[finger] ?? 0) + item.attempts;
    errors[finger] = (errors[finger] ?? 0) + item.errors;
  }
  final rows = <_FingerRow>[];
  for (final code in order) {
    final total = attempts[code] ?? 0;
    if (total > 0) {
      rows.add(_FingerRow(code, 1 - (errors[code] ?? 0) / total));
    }
  }
  return rows;
}
