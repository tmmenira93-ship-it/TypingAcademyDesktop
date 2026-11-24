import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typing_academy_desktop/widgets/keyboard_guide.dart';

void main() {
  test('finger mapping follows touch-typing rules', () {
    expect(KeyboardGuide.fingerFor('a'), 'LP');
    expect(KeyboardGuide.fingerFor('f'), 'LI');
    expect(KeyboardGuide.fingerFor('j'), 'RI');
    expect(KeyboardGuide.fingerFor(';'), 'RP');
    expect(KeyboardGuide.fingerFor('A'), 'LP');
    expect(KeyboardGuide.fingerFor('?'), 'RP');
    expect(KeyboardGuide.fingerFor(' '), 'T');
    expect(KeyboardGuide.fingerFor('é'), isNull);
  });

  testWidgets('keyboard paints for letters, capitals, symbols, space and no target', (tester) async {
    for (final target in <String?>['a', 'A', '?', '"', '5', ' ', null]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(width: 900, height: 360, child: KeyboardGuide(target: target)),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    }
  });
}
