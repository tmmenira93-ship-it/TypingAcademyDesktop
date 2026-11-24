import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../state/app_state.dart';
import '../widgets/app_shell.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.l10n;
    final colors = Theme.of(context).colorScheme;

    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _open(context);
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            body: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [colors.primary, colors.tertiary],
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.keyboard_rounded, size: 96, color: colors.onPrimary),
                          const SizedBox(height: 24),
                          Text(
                            t.appName,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: colors.onPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            t.tagline,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: colors.onPrimary.withOpacity(0.92),
                                ),
                          ),
                          const SizedBox(height: 32),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 12,
                            children: [
                              Chip(
                                avatar: const Icon(Icons.wifi_off, size: 18),
                                label: Text(t.offlineReady),
                                backgroundColor: colors.onPrimary.withOpacity(0.16),
                                labelStyle: TextStyle(color: colors.onPrimary),
                              ),
                              Chip(
                                label: const Text('Windows / macOS / Linux'),
                                backgroundColor: colors.onPrimary.withOpacity(0.16),
                                labelStyle: TextStyle(color: colors.onPrimary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 36),
                          FilledButton.icon(
                            key: const Key('startLearningButton'),
                            onPressed: () => _open(context),
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Text(t.startLearning),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: colors.onPrimary,
                              foregroundColor: colors.primary,
                              minimumSize: const Size(240, 56),
                              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'v${AppConstants.appVersion}',
                            style: TextStyle(color: colors.onPrimary.withOpacity(0.8)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _open(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const AppShell()),
    );
  }
}
