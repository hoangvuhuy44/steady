import 'package:flutter_test/flutter_test.dart';
import 'package:steady/models/activity_type.dart';
import 'package:steady/state/steady_store.dart';

import 'helpers/fake_activity_repository.dart';

ActivityLog savedLog(
  String id,
  String date,
  int minutes, {
  String owner = 'A',
}) => ActivityLog(
  id: id,
  ownerId: owner,
  type: ActivityType.walk,
  minutes: minutes,
  // Deliberately unrelated to the saved date: travel must not move a log.
  createdAt: DateTime.utc(2020, 1, 1),
  localDate: date,
);

void main() {
  for (final today in [
    DateTime(2026, 10, 9),
    DateTime(2026, 10, 2),
    DateTime(2027, 1, 2),
    DateTime(2028, 3, 2),
  ]) {
    test('7-day window includes today and day -6 at $today', () async {
      final day = DateTime.utc(today.year, today.month, today.day);
      String key(int offset) =>
          ActivityLog.dateKey(day.add(Duration(days: offset)));
      final repo = FakeActivityRepository()
        ..saved.addAll([
          savedLog('outside', key(-7), 100),
          savedLog('first', key(-6), 15),
          savedLog('repeat', key(-6), 25),
          savedLog('middle', key(-4), 30),
          savedLog('today', key(0), 40),
          savedLog('future', key(1), 200),
          savedLog('other-owner', key(0), 300, owner: 'B'),
        ]);
      final store = SteadyStore(now: () => today, activityRepository: repo);
      addTearDown(store.dispose);
      await store.setActivityOwner('A');
      final metrics = store.activityMetrics;
      expect(metrics.activeDays, 3);
      expect(metrics.minutes, 110);
      expect(metrics.checkedInToday, isTrue);
      expect(metrics.latestToday?.id, 'today');
      expect(metrics.targetReached, isFalse);
      expect(metrics.days.map(ActivityLog.dateKey), [
        for (var offset = -6; offset <= 0; offset++) key(offset),
      ]);
      expect(metrics.days.map(metrics.isActiveOn), [
        true,
        false,
        true,
        false,
        false,
        false,
        true,
      ]);
      expect(metrics.isActiveOn(day.add(const Duration(days: 1))), isFalse);
      await store.setActivityOwner('B');
      expect(store.activityMetrics.activeDays, 1);
      expect(store.activityMetrics.minutes, 300);
      await store.setActivityOwner(null);
      expect(store.activityMetrics.activeDays, 0);
      expect(store.activityMetrics.minutes, 0);
    });
  }

  test(
    'streak ending yesterday lasts all today and resets after a missed day',
    () async {
      var now = DateTime(2027, 1, 1);
      final repo = FakeActivityRepository();
      // A streak may extend beyond the 7-day metrics window and across a year.
      for (var offset = 1; offset <= 10; offset++) {
        repo.saved.add(
          savedLog(
            '$offset',
            ActivityLog.dateKey(DateTime.utc(2027, 1, 1 - offset)),
            10,
          ),
        );
      }
      repo.saved.add(savedLog('future', '2027-01-02', 50));
      final store = SteadyStore(now: () => now, activityRepository: repo);
      addTearDown(store.dispose);
      await store.setActivityOwner('A');
      expect(store.checkedInToday, isFalse);
      expect(store.streak, 10);
      expect(store.activityMetrics.activeDays, 6);
      expect(store.activityMetrics.minutes, 60);
      now = DateTime(2027, 1, 1, 23, 59, 59);
      expect(store.streak, 10);
      // Skip January 1. The future saved row becomes today's single-day streak.
      now = DateTime(2027, 1, 2);
      expect(store.streak, 1);
      now = DateTime(2027, 1, 4);
      expect(store.streak, 0);
      expect(store.checkedInToday, isFalse);
    },
  );

  test(
    'today continues yesterday streak; duplicates do not extend it',
    () async {
      var now = DateTime(2026, 10, 8, 23, 59);
      final store = SteadyStore(
        now: () => now,
        activityRepository: FakeActivityRepository(),
      );
      addTearDown(store.dispose);
      await store.setActivityOwner('A');
      await store.logActivity(ActivityType.walk, 15);
      now = DateTime(2026, 10, 9);
      expect(store.streak, 1);
      expect(store.activityMetrics.latestToday, isNull);
      await store.logActivity(ActivityType.run, 25);
      await store.logActivity(ActivityType.swim, 30);
      expect(store.streak, 2);
      expect(store.activityMetrics.activeDays, 2);
      expect(store.activityMetrics.minutes, 70);
      expect(store.activityMetrics.latestToday?.type, ActivityType.swim);
      now = DateTime(2026, 10, 11);
      expect(store.streak, 0);
      expect(store.activityMetrics.latestToday, isNull);
    },
  );

  test(
    '5/7 goal is reached even when today and yesterday are missed',
    () async {
      final repo = FakeActivityRepository()
        ..saved.addAll([
          for (var day = 3; day <= 7; day++)
            savedLog('$day', '2026-10-0$day', 20),
          savedLog('repeat', '2026-10-03', 30),
        ]);
      final store = SteadyStore(
        now: () => DateTime(2026, 10, 9),
        activityRepository: repo,
      );
      addTearDown(store.dispose);
      await store.setActivityOwner('A');
      expect(store.activityMetrics.activeDays, 5);
      expect(store.activityMetrics.minutes, 130);
      expect(store.activityMetrics.targetReached, isTrue);
      expect(store.streak, 0);
      expect(store.checkedInToday, isFalse);
      expect(store.activityMetrics.latestToday, isNull);
    },
  );

  test(
    'store clock controls date, next midnight and refresh notifications',
    () {
      var now = DateTime(2026, 12, 31, 23, 59, 50);
      final store = SteadyStore(
        now: () => now,
        activityRepository: FakeActivityRepository(),
      );
      addTearDown(store.dispose);
      expect(store.timeUntilNextDay, const Duration(seconds: 10));
      var notifications = 0;
      store.addListener(() => notifications++);
      now = DateTime(2027, 1, 1);
      store.refreshActivityDate();
      expect(notifications, 1);
      expect(store.activityMetrics.today, DateTime.utc(2027, 1, 1));
      expect(store.timeUntilNextDay, const Duration(days: 1));
    },
  );
}
