import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../state/app_state.dart';
import '../widgets/app_card.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.l10n;
    final theme = Theme.of(context);
    const icons = <String, IconData>{
      'flag': Icons.flag,
      'school': Icons.school,
      'emoji_events': Icons.emoji_events,
      'verified': Icons.verified,
      'speed': Icons.speed,
      'star': Icons.star,
      'timer': Icons.timer,
      'sports_esports': Icons.sports_esports,
      'workspace_premium': Icons.workspace_premium,
    };
    final total = state.achievements.length;
    final unlocked = state.achievements.where((item) => item.unlocked).length;

    return Padding(
      padding: const EdgeInsets.all(28),
      child: ListView(
        children: [
          Text(t.achievements, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '$unlocked / $total ${t.unlockedLabel}',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const Icon(Icons.star_rounded, color: AppTheme.accent),
                      const SizedBox(width: 4),
                      Text('${state.stats.totalStars}', style: theme.textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(value: total == 0 ? 0 : unlocked / total, minHeight: 10),
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
              for (final item in state.achievements)
                SizedBox(
                  width: 320,
                  child: Opacity(
                    opacity: item.unlocked ? 1 : 0.6,
                    child: AppCard(
                      color: item.unlocked ? AppTheme.accent.withOpacity(0.12) : null,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: item.unlocked ? AppTheme.accent : theme.colorScheme.surfaceContainerHighest,
                              child: Icon(
                                icons[item.icon] ?? Icons.military_tech,
                                color: item.unlocked ? Colors.white : theme.disabledColor,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title(state.isArabic),
                                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(item.description(state.isArabic), style: theme.textTheme.bodySmall),
                                ],
                              ),
                            ),
                            Icon(
                              item.unlocked ? Icons.check_circle : Icons.lock_outline,
                              size: 20,
                              color: item.unlocked ? AppTheme.success : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
