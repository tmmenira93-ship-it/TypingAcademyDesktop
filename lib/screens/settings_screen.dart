import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/app_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.l10n;
    final theme = Theme.of(context);

    Widget toggle(String label, bool value, void Function(bool) onChanged) {
      return SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(label),
        value: value,
        onChanged: onChanged,
      );
    }

    return Padding(
      padding: const EdgeInsets.all(28),
      child: ListView(
        children: [
          Text(t.settings, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          _Section(
            title: t.settingsAppearance,
            icon: Icons.palette_outlined,
            children: [
              Text(t.theme, style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment(value: ThemeMode.system, label: Text(t.systemTheme)),
                  ButtonSegment(value: ThemeMode.light, label: Text(t.lightTheme)),
                  ButtonSegment(value: ThemeMode.dark, label: Text(t.darkTheme)),
                ],
                selected: {state.settings.themeMode},
                onSelectionChanged: (value) => state.setTheme(value.first),
              ),
              const SizedBox(height: 16),
              Text('${t.fontSize}: ${state.settings.fontScale.toStringAsFixed(1)}x', style: theme.textTheme.labelLarge),
              Slider(
                min: 0.9,
                max: 1.6,
                divisions: 7,
                value: state.settings.fontScale,
                onChanged: state.setFontScale,
              ),
            ],
          ),
          _Section(
            title: t.settingsGuides,
            icon: Icons.keyboard_alt_outlined,
            children: [
              toggle(t.showKeyboardGuide, state.settings.showKeyboard, (value) => state.setPracticeOptions(showKeyboard: value)),
              toggle(t.showHandsGuide, state.settings.showHands, (value) => state.setPracticeOptions(showHands: value)),
              toggle(t.showLiveStats, state.settings.showLiveStats, (value) => state.setPracticeOptions(showLiveStats: value)),
            ],
          ),
          _Section(
            title: t.settingsFeedback,
            icon: Icons.volume_up_outlined,
            children: [
              toggle(t.voiceOverLabel, state.settings.voiceOver, (value) => state.setPracticeOptions(voiceOver: value)),
              toggle(t.keySoundsLabel, state.settings.keySounds, (value) => state.setPracticeOptions(keySounds: value)),
            ],
          ),
          _Section(
            title: t.settingsRules,
            icon: Icons.rule_rounded,
            children: [
              toggle(t.blockOnError, state.settings.blockOnError, (value) => state.setPracticeOptions(blockOnError: value)),
              toggle(t.allowBackspace, state.settings.allowBackspace, (value) => state.setPracticeOptions(allowBackspace: value)),
            ],
          ),
          _Section(
            title: t.settingsData,
            icon: Icons.shield_outlined,
            children: [
              Text(t.privacyNote),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.tonal(onPressed: state.backup, child: Text(t.backup)),
                  FilledButton.tonal(
                    onPressed: () async {
                      try {
                        await state.restore();
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(t.none)),
                          );
                        }
                      }
                    },
                    child: Text(t.restore),
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          content: Text(t.confirmDelete),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(t.cancel)),
                            FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(t.confirm)),
                          ],
                        ),
                      );
                      if (ok == true) {
                        await state.deleteHistory();
                      }
                    },
                    child: Text(t.deleteHistory),
                  ),
                ],
              ),
              if (state.statusMessage != null) ...[
                const SizedBox(height: 16),
                Text(state.statusMessage!),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.icon, required this.children});

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AppCard(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: theme.colorScheme.primary),
                  const SizedBox(width: 10),
                  Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 8),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
