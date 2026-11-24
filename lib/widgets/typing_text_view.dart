import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../engine/typing_engine.dart';

/// The text being typed: one paragraph made of a few coloured runs (not one widget per
/// character). Shared by the practice screen and the replay screen.
class TypingTextView extends StatelessWidget {
  const TypingTextView({super.key, required this.engine, required this.fontSize});

  final TypingEngine engine;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // The text is Latin: keep it left-to-right even in the Arabic UI.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Text.rich(
        TextSpan(children: _spans(scheme)),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontSize,
          height: 1.6,
          letterSpacing: 1,
          fontFamily: AppTheme.monoFamily,
          fontFamilyFallback: AppTheme.monoFallback,
        ),
      ),
    );
  }

  List<InlineSpan> _spans(ColorScheme scheme) {
    final target = engine.target;
    final n = target.length;
    final caret = engine.isFinished ? -1 : engine.typedLength;
    final spans = <InlineSpan>[];
    var i = 0;
    while (i < n) {
      if (i == caret) {
        spans.add(TextSpan(
          text: target[i],
          style: TextStyle(
            color: scheme.onPrimaryContainer,
            backgroundColor: scheme.primaryContainer,
            fontWeight: FontWeight.w700,
          ),
        ));
        i++;
        continue;
      }
      final status = engine.statusAt(i);
      var j = i + 1;
      while (j < n && j != caret && engine.statusAt(j) == status) {
        j++;
      }
      spans.add(TextSpan(text: target.substring(i, j), style: _styleFor(status, scheme)));
      i = j;
    }
    return spans;
  }

  TextStyle _styleFor(CharStatus status, ColorScheme scheme) {
    return switch (status) {
      CharStatus.correct => const TextStyle(color: AppTheme.success),
      CharStatus.incorrect => TextStyle(
          color: AppTheme.danger,
          backgroundColor: AppTheme.danger.withOpacity(0.15),
        ),
      CharStatus.pending || CharStatus.extra => TextStyle(color: scheme.onSurface.withOpacity(0.55)),
    };
  }
}
