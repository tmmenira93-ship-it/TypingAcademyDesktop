import 'package:flutter_test/flutter_test.dart';
import 'package:typing_academy_desktop/state/app_state.dart';

void main() {
  final now = DateTime(2026, 11, 17, 14);

  test('streak counts consecutive days ending today', () {
    expect(AppState.streakFrom(['2026-11-17', '2026-11-16', '2026-11-15', '2026-11-12'], now), 3);
  });

  test('streak survives until the end of the day after the last practice', () {
    expect(AppState.streakFrom(['2026-11-16', '2026-11-15'], now), 2);
  });

  test('streak is zero after a missed day or with no practice', () {
    expect(AppState.streakFrom(['2026-11-14'], now), 0);
    expect(AppState.streakFrom([], now), 0);
  });

  test('streak crosses a month boundary', () {
    expect(AppState.streakFrom(['2026-12-01', '2026-11-30', '2026-11-29'], DateTime(2026, 12, 1, 9)), 3);
  });
}
