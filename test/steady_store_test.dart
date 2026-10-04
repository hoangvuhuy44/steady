import 'package:flutter_test/flutter_test.dart';
import 'package:steady/models/activity_type.dart';
import 'package:steady/state/steady_store.dart';

void main() {
  test('points and streak use actual check-ins, including missed days', () {
    var now = DateTime(2026, 10, 1, 9);
    final store = SteadyStore(now: () => now);
    addTearDown(store.dispose);
    expect(store.points, 0);
    expect(store.streak, 0);
    expect(store.checkedInToday, isFalse);
    store.logActivity(ActivityType.walk, 30);
    expect(store.points, 20);
    expect(store.streak, 1);
    expect(store.checkedInToday, isTrue);
    store.logActivity(ActivityType.run, 20);
    expect(store.points, 25);
    expect(store.streak, 1);
    now = DateTime(2026, 10, 2, 9);
    expect(store.streak, 1);
    expect(store.checkedInToday, isFalse);
    store.logActivity(ActivityType.swim, 20);
    expect(store.streak, 2);
    expect(store.points, 45);
    now = DateTime(2026, 10, 4, 9);
    expect(store.streak, 0);
    store.logActivity(ActivityType.gym, 30);
    expect(store.streak, 1);
    expect(store.points, 65);
  });
}
