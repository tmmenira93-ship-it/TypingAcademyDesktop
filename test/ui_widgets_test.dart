import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typing_academy_desktop/widgets/app_card.dart';
import 'package:typing_academy_desktop/widgets/progress_ring.dart';
import 'package:typing_academy_desktop/widgets/star_burst.dart';
import 'package:typing_academy_desktop/widgets/trend_chart.dart';

void main() {
  testWidgets('shared UI widgets render without errors', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                AppCard(child: Text('card')),
                ProgressRing(value: 0.6, color: Colors.blue, child: Text('6')),
                TrendChart(values: [10, 20, 15, 30], color: Colors.green),
                TrendChart(values: [], color: Colors.green),
                TrendChart(values: [12], color: Colors.green),
                StarBurst(count: 3),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 1500));
    expect(find.text('card'), findsOneWidget);
    expect(find.byIcon(Icons.star_rounded), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });
}
