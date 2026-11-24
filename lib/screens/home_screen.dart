import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/lesson.dart';
import '../state/app_state.dart';
import '../widgets/app_card.dart';
import '../widgets/progress_ring.dart';
import '../widgets/stat_card.dart';
import 'games_screen.dart';
import 'practice_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final next = state.continueLesson;
    final last = state.lastLesson;
    final total = state.lessons.length;
    final completed = state.lessons.where((lesson) => state.progress[lesson.id]?.completed == true).length;
    final weak = state.weakKeys;

    final goalMs = AppState.dailyGoalMinutes * 60000;
    final goalProgress = goalMs == 0 ? 0.0 : (state.todayMs / goalMs).clamp(0.0, 1.0).toDouble();
    final minutesToday = state.todayMs ~/ 60000;

    void openLesson(Lesson lesson) {
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => PracticeScreen(lesson: lesson)));
    }

    final hero = _HeroCard(
      caption: state.stats.totalAttempts == 0
          ? t.noProgressYet
          : '${t.lastLesson}: ${last?.title(state.isArabic) ?? t.none}',
      title: next?.title(state.isArabic) ?? t.completedLabel,
      body: next?.instructions(state.isArabic),
      buttonLabel: t.continueLesson,
      onPressed: next == null ? null : () => openLesson(next),
    );

    final goal = AppCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(t.dailyGoal, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            ProgressRing(
              value: goalProgress,
              color: goalProgress >= 1 ? AppTheme.success : scheme.primary,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$minutesToday', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                  Text('/ ${AppState.dailyGoalMinutes} ${t.minutesShort}', style: theme.textTheme.labelMedium),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              goalProgress >= 1 ? t.goalReached : t.goalKeepGoing,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_fire_department_rounded, color: Color(0xFFF97316)),
                const SizedBox(width: 6),
                Text('${state.streakDays} ${t.streakDaysLabel}', style: theme.textTheme.titleSmall),
              ],
            ),
          ],
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(28),
      child: ListView(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(t.home, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
              ),
              Chip(
                avatar: const Icon(Icons.workspace_premium_outlined, size: 18),
                label: Text('${t.yourLevel}: ${state.learnerLevel()}'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, box) {
              if (box.maxWidth >= 820) {
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: hero),
                      const SizedBox(width: 16),
                      SizedBox(width: 280, child: goal),
                    ],
                  ),
                );
              }
              return Column(children: [hero, const SizedBox(height: 16), goal]);
            },
          ),
          const SizedBox(height: 20),
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(t.courseProgress, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      ),
                      Text('$completed / $total ${t.lessonsDone}', style: theme.textTheme.labelLarge),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(value: total == 0 ? 0 : completed / total, minHeight: 10),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(
                width: 240,
                child: StatCard(label: t.avgWpm, value: state.stats.averageWpm.toStringAsFixed(1), icon: Icons.speed),
              ),
              SizedBox(
                width: 240,
                child: StatCard(
                  label: t.avgAccuracy,
                  value: '${state.stats.averageAccuracy.toStringAsFixed(1)}%',
                  icon: Icons.verified,
                  color: AppTheme.success,
                ),
              ),
              SizedBox(
                width: 240,
                child: StatCard(
                  label: t.stars,
                  value: '${state.stats.totalStars}',
                  icon: Icons.star_rounded,
                  color: AppTheme.accent,
                ),
              ),
            ],
          ),
          if (weak.isNotEmpty) ...[
            const SizedBox(height: 16),
            AppCard(
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Icon(Icons.track_changes_rounded, size: 36, color: scheme.tertiary),
                title: Text(t.weakKeysTitle, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                subtitle: Text(weak.map((item) => item.char).join('  ')),
                trailing: FilledButton.tonal(
                  onPressed: () {
                    final lesson = state.dynamicLesson();
                    if (lesson != null) {
                      openLesson(lesson);
                    }
                  },
                  child: Text(t.practiceNow),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          AppCard(
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Icon(Icons.sports_esports_rounded, size: 40, color: scheme.primary),
              title: Text(t.gamesTitle, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              subtitle: Text('${t.gameName}, ${t.letterPopName}, ${t.raceName}, ${t.sprintName}, ${t.huntName}, ${t.magicTilesName}'),
              trailing: FilledButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GamesScreen()));
                },
                child: Text(t.playGame),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.caption,
    required this.title,
    required this.body,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String caption;
  final String title;
  final String? body;
  final String buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, scheme.tertiary],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(caption, style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onPrimary.withOpacity(0.85))),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(color: scheme.onPrimary, fontWeight: FontWeight.w800),
          ),
          if (body != null) ...[
            const SizedBox(height: 8),
            Text(
              body!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onPrimary.withOpacity(0.9)),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: scheme.onPrimary,
              foregroundColor: scheme.primary,
            ),
            onPressed: onPressed,
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(buttonLabel),
          ),
        ],
      ),
    );
  }
}
