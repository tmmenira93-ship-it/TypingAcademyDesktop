import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typing_academy_desktop/main.dart';
import 'package:typing_academy_desktop/state/app_state.dart';

void main() {
  testWidgets('splash window shows app name and start button', (tester) async {
    final state = AppState();
    await tester.pumpWidget(TypingAcademyApp(state: state));

    expect(find.text('Typing Academy'), findsWidgets);
    expect(find.text('Start Learning'), findsOneWidget);
    expect(find.byKey(const Key('startLearningButton')), findsOneWidget);
  });

  testWidgets('start learning opens the home shell', (tester) async {
    final state = AppState();
    await tester.pumpWidget(TypingAcademyApp(state: state));

    await tester.tap(find.byKey(const Key('startLearningButton')));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsWidgets);
    expect(find.textContaining('Your level'), findsOneWidget);
  });
}
