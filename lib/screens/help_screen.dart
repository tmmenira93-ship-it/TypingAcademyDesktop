import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../state/app_state.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.l10n;

    return Padding(
      padding: const EdgeInsets.all(28),
      child: ListView(
        children: [
          Text(t.helpTitle, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Text(t.helpBody, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 24),
          const ListTile(
            leading: Icon(Icons.looks_one),
            title: Text('Home row first'),
            subtitle: Text('A S D F and J K L ; before other keys.'),
          ),
          const ListTile(
            leading: Icon(Icons.looks_two),
            title: Text('Accuracy before speed'),
            subtitle: Text('Green is correct. Red is a mistake. Backspace is allowed.'),
          ),
          const ListTile(
            leading: Icon(Icons.looks_3),
            title: Text('Progress is local'),
            subtitle: Text('Closing the app keeps your results on this computer.'),
          ),
          const SizedBox(height: 24),
          const Text('${AppConstants.appName} ${AppConstants.appVersion}'),
          const Text('Windows 10 21H2+, Windows 11, macOS 10.14+, Debian 12 / Ubuntu 22.04+ / Fedora 38+.'),
        ],
      ),
    );
  }
}
