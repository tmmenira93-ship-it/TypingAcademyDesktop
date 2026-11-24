import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/key_stat.dart';
import '../models/lesson.dart';
import '../state/app_state.dart';
import '../widgets/app_card.dart';
import '../widgets/star_row.dart';
import 'practice_screen.dart';

class LessonMapScreen extends StatelessWidget {
  const LessonMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.l10n;
    final stages = state.stages;
    final currentId = state.continueLesson?.id;
    final weak = state.weakKeys;
    final doneAll = state.lessons.where((lesson) => state.progress[lesson.id]?.completed == true).length;

    // Builder: with ~150 lessons only the stages on screen are built.
    return Padding(
      padding: const EdgeInsets.all(28),
      child: ListView.builder(
        itemCount: stages.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.lessons,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text('$doneAll / ${state.lessons.length} ${t.lessonsDone}'),
                ],
              ),
            );
          }
          if (index == 1) {
            return weak.isEmpty
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _WeakKeysCard(state: state, weak: weak),
                  );
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _StageCard(stage: stages[index - 2], state: state, currentId: currentId, index: index - 2),
          );
        },
      ),
    );
  }
}

class _WeakKeysCard extends StatelessWidget {
  const _WeakKeysCard({required this.state, required this.weak});

  final AppState state;
  final List<KeyStat> weak;

  @override
  Widget build(BuildContext context) {
    final t = state.l10n;
    final theme = Theme.of(context);
    return AppCard(
      color: theme.colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(Icons.track_changes_rounded, size: 36, color: theme.colorScheme.onTertiaryContainer),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.weakKeysTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(t.weakKeysSubtitle, style: TextStyle(color: theme.colorScheme.onTertiaryContainer)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final item in weak)
                        Chip(label: Text('${item.char}  ${(item.errorRate * 100).round()}%')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            FilledButton.icon(
              onPressed: () {
                final lesson = state.dynamicLesson();
                if (lesson != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => PracticeScreen(lesson: lesson)),
                  );
                }
              },
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(t.practiceNow),
            ),
          ],
        ),
      ),
    );
  }
}

class _StageCard extends StatelessWidget {
  const _StageCard({
    required this.stage,
    required this.state,
    required this.currentId,
    required this.index,
  });

  static const List<Color> _accents = [
    Color(0xFF2563EB),
    Color(0xFF16A34A),
    Color(0xFFF59E0B),
    Color(0xFF9333EA),
    Color(0xFFDB2777),
    Color(0xFF0891B2),
    Color(0xFFEA580C),
  ];

  final LessonStage stage;
  final AppState state;
  final String? currentId;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = _accents[index % _accents.length];
    final total = stage.lessons.length;
    final done = stage.lessons.where((lesson) => state.progress[lesson.id]?.completed == true).length;
    final hasCurrent = stage.lessons.any((lesson) => lesson.id == currentId);

    // Only the stage you are working on starts open, so the map stays short and scannable.
    return AppCard(
      child: ExpansionTile(
        key: PageStorageKey<String>('stage-${stage.id}'),
        initiallyExpanded: hasCurrent,
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        leading: CircleAvatar(
          backgroundColor: accent.withOpacity(0.15),
          child: done == total && total > 0
              ? Icon(Icons.check_rounded, color: accent)
              : Text('${index + 1}', style: TextStyle(color: accent, fontWeight: FontWeight.w800)),
        ),
        title: Text(stage.title(state.isArabic), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(value: total == 0 ? 0 : done / total, minHeight: 6, color: accent),
                ),
              ),
              const SizedBox(width: 12),
              Text('$done / $total', style: theme.textTheme.labelLarge),
            ],
          ),
        ),
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final lesson in stage.lessons)
                  SizedBox(
                    width: 260,
                    child: _LessonCard(lesson: lesson, state: state, isCurrent: lesson.id == currentId),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({required this.lesson, required this.state, required this.isCurrent});

  final Lesson lesson;
  final AppState state;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final t = state.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final unlocked = state.isUnlocked(lesson);
    final item = state.progress[lesson.id];
    final completed = item?.completed == true;
    final current = unlocked && !completed && isCurrent;

    final Color background;
    if (completed) {
      background = AppTheme.success.withOpacity(0.12);
    } else if (current) {
      background = scheme.primaryContainer;
    } else {
      background = scheme.surfaceContainerHighest.withOpacity(unlocked ? 1 : 0.5);
    }

    final Widget badge;
    if (completed) {
      badge = const Icon(Icons.check_rounded, size: 18, color: Colors.white);
    } else if (unlocked) {
      badge = Text('${lesson.order}', style: TextStyle(color: scheme.onPrimary, fontWeight: FontWeight.w700, fontSize: 12));
    } else {
      badge = Icon(Icons.lock_outline, size: 16, color: scheme.onSurfaceVariant);
    }
    final badgeColor = completed ? AppTheme.success : (unlocked ? scheme.primary : scheme.surfaceContainerHigh);

    final Widget footerLeft;
    if (!lesson.isScored) {
      footerLeft = Text(t.introLabel, style: theme.textTheme.labelMedium?.copyWith(color: scheme.secondary));
    } else if (item != null) {
      footerLeft = StarRow(count: item.bestStars, size: 16);
    } else {
      footerLeft = const SizedBox(height: 16);
    }

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: unlocked
            ? () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => PracticeScreen(lesson: lesson)),
                );
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(radius: 16, backgroundColor: badgeColor, child: badge),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      lesson.title(state.isArabic),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                lesson.isScored
                    ? '${t.goal}: ${lesson.goalWpm} ${t.wpm}  •  ${lesson.masteryAccuracy.toStringAsFixed(0)}%'
                    : t.introNoScore,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  footerLeft,
                  const Spacer(),
                  if (current)
                    Text(t.currentLabel, style: theme.textTheme.labelMedium?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700))
                  else if (!unlocked)
                    Text(t.locked, style: theme.textTheme.labelMedium)
                  else if (completed)
                    Text(t.completedLabel, style: theme.textTheme.labelMedium?.copyWith(color: AppTheme.success, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
