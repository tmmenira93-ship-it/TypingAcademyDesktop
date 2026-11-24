import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = state.l10n;

    return Padding(
      padding: const EdgeInsets.all(28),
      child: ListView(
        children: [
          Text(t.language, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(t.chooseLanguage),
          const SizedBox(height: 20),
          RadioListTile<String>(
            title: Text(t.english),
            subtitle: Text(t.qwerty),
            value: 'en',
            groupValue: state.settings.languageCode,
            onChanged: (value) {
              if (value != null) {
                state.setLanguage(value, 'qwerty');
              }
            },
          ),
          RadioListTile<String>(
            title: Text(t.arabic),
            subtitle: Text(t.arabicLayout),
            value: 'ar',
            groupValue: state.settings.languageCode,
            onChanged: (value) {
              if (value != null) {
                state.setLanguage(value, 'arabic');
              }
            },
          ),
        ],
      ),
    );
  }
}
