import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../screens/achievements_screen.dart';
import '../screens/help_screen.dart';
import '../screens/home_screen.dart';
import '../screens/language_screen.dart';
import '../screens/lesson_map_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/stats_screen.dart';
import '../state/app_state.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int index = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.l10n;
    final theme = Theme.of(context);
    final pages = <Widget>[
      const HomeScreen(),
      const LessonMapScreen(),
      const LanguageScreen(),
      const StatsScreen(),
      const AchievementsScreen(),
      const SettingsScreen(),
      const HelpScreen(),
    ];
    final destinations = [
      NavigationRailDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: Text(t.home)),
      NavigationRailDestination(icon: const Icon(Icons.map_outlined), selectedIcon: const Icon(Icons.map), label: Text(t.lessons)),
      NavigationRailDestination(icon: const Icon(Icons.language_outlined), selectedIcon: const Icon(Icons.language), label: Text(t.language)),
      NavigationRailDestination(icon: const Icon(Icons.bar_chart_outlined), selectedIcon: const Icon(Icons.bar_chart), label: Text(t.statistics)),
      NavigationRailDestination(icon: const Icon(Icons.emoji_events_outlined), selectedIcon: const Icon(Icons.emoji_events), label: Text(t.achievements)),
      NavigationRailDestination(icon: const Icon(Icons.settings_outlined), selectedIcon: const Icon(Icons.settings), label: Text(t.settings)),
      NavigationRailDestination(icon: const Icon(Icons.help_outline), selectedIcon: const Icon(Icons.help), label: Text(t.help)),
    ];

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, box) {
          // Wide windows get a labelled rail; narrow ones keep the compact icon rail.
          final wide = box.maxWidth >= 1000;
          return Row(
            children: [
              NavigationRail(
                selectedIndex: index,
                onDestinationSelected: (value) => setState(() => index = value),
                extended: wide,
                labelType: wide ? NavigationRailLabelType.none : NavigationRailLabelType.all,
                leading: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: wide ? 12 : 0),
                  child: Column(
                    children: [
                      if (wide)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.keyboard_rounded, color: theme.colorScheme.primary, size: 32),
                            const SizedBox(width: 10),
                            Text(
                              AppConstants.appName,
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ],
                        )
                      else ...[
                        Icon(Icons.keyboard_rounded, color: theme.colorScheme.primary, size: 36),
                        const SizedBox(height: 8),
                        Text(
                          AppConstants.appName,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                      if (state.streakDays > 0) ...[
                        const SizedBox(height: 14),
                        _StreakChip(days: state.streakDays, label: t.streakDaysLabel, compact: !wide),
                      ],
                    ],
                  ),
                ),
                destinations: destinations,
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: SizedBox.expand(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: KeyedSubtree(key: ValueKey<int>(index), child: pages[index]),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.days, required this.label, required this.compact});

  final int days;
  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    const flame = Color(0xFFF97316);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: flame.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department_rounded, color: flame, size: 20),
          const SizedBox(width: 4),
          Text('$days', style: const TextStyle(fontWeight: FontWeight.w800, color: flame)),
          if (!compact) ...[
            const SizedBox(width: 6),
            Text(label, style: Theme.of(context).textTheme.labelMedium),
          ],
        ],
      ),
    );
  }
}
