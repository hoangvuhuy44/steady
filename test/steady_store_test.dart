import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:steady/models/activity_type.dart';
import 'package:steady/state/steady_store.dart';

import 'helpers/fake_activity_repository.dart';

void main() {
  test(
    'delayed guest identity cannot overwrite a later signed-in owner',
    () async {
      final identity = Completer<String>();
      final repo = FakeActivityRepository()
        ..onGuestOwner = () => identity.future;
      final store = SteadyStore(activityRepository: repo);
      addTearDown(store.dispose);
      final guestLoading = store.setActivityUser(null);
      await Future<void>.delayed(Duration.zero);
      await store.setActivityUser('A');
      await store.logActivity(ActivityType.run, 30);
      identity.complete('guest:device');
      await guestLoading;
      expect(store.activityOwnerId, 'A');
      expect(store.logs.single.ownerId, 'A');
    },
  );

  test(
    'guest identity storage failure can retry without a successful fake save',
    () async {
      final repo = FakeActivityRepository()
        ..onGuestOwner = () async => throw StateError('database unavailable');
      final store = SteadyStore(activityRepository: repo);
      addTearDown(store.dispose);
      await store.setActivityUser(null);
      expect(store.activityLoadError, isNotNull);
      expect(store.canLogActivity, isFalse);
      expect(await store.logActivity(ActivityType.walk, 30), isNull);
      repo.onGuestOwner = null;
      await store.reloadActivities();
      expect(store.activityLoadError, isNull);
      expect(store.canLogActivity, isTrue);
      expect(await store.logActivity(ActivityType.walk, 30), 20);
    },
  );
  test(
    'points and streak use actual check-ins, including missed days',
    () async {
      var now = DateTime(2026, 10, 1, 9);
      final store = SteadyStore(
        now: () => now,
        activityRepository: FakeActivityRepository(),
      );
      addTearDown(store.dispose);
      await store.setActivityOwner('A');
      expect(store.points, 0);
      expect(store.streak, 0);
      expect(store.checkedInToday, isFalse);
      await store.logActivity(ActivityType.walk, 30);
      expect(store.points, 20);
      expect(store.streak, 1);
      expect(store.checkedInToday, isTrue);
      await store.logActivity(ActivityType.run, 20);
      expect(store.points, 25);
      expect(store.streak, 1);
      now = DateTime(2026, 10, 2, 9);
      expect(store.streak, 1);
      expect(store.checkedInToday, isFalse);
      await store.logActivity(ActivityType.swim, 20);
      expect(store.streak, 2);
      expect(store.points, 45);
      now = DateTime(2026, 10, 4, 9);
      expect(store.streak, 0);
      await store.logActivity(ActivityType.gym, 30);
      expect(store.streak, 1);
      expect(store.points, 65);
    },
  );

  test(
    'read failure preserves history and points; retry restores saving',
    () async {
      final repo = FakeActivityRepository();
      final store = SteadyStore(activityRepository: repo);
      addTearDown(store.dispose);
      await store.setActivityOwner('A');
      await store.logActivity(ActivityType.walk, 30);
      repo.failRead = true;
      await store.reloadActivities();
      expect(store.logs, hasLength(1));
      expect(store.points, 20);
      expect(store.activityLoadError, isNotNull);
      expect(store.canLogActivity, isFalse);
      expect(await store.logActivity(ActivityType.run, 20), isNull);
      repo.failRead = false;
      await store.reloadActivities();
      expect(store.activityLoadError, isNull);
      expect(store.canLogActivity, isTrue);
      expect(store.points, 20);
    },
  );

  test(
    'initial read failure never allows a write until successful retry',
    () async {
      final repo = FakeActivityRepository()..failRead = true;
      final store = SteadyStore(activityRepository: repo);
      addTearDown(store.dispose);
      await store.setActivityOwner('A');
      expect(store.activityLoading, isFalse);
      expect(store.activityLoadError, isNotNull);
      expect(await store.logActivity(ActivityType.walk, 30), isNull);
      expect(repo.writes, 0);
      repo.failRead = false;
      await store.reloadActivities();
      expect(await store.logActivity(ActivityType.walk, 30), 20);
    },
  );

  test('write failure awards nothing and can be retried', () async {
    final repo = FakeActivityRepository()..failWrite = true;
    final store = SteadyStore(activityRepository: repo);
    addTearDown(store.dispose);
    await store.setActivityOwner('A');
    expect(await store.logActivity(ActivityType.walk, 30), isNull);
    expect(store.logs, isEmpty);
    expect(store.points, 0);
    expect(store.streak, 0);
    expect(store.activitySaving, isFalse);
    expect(store.activitySaveError, isNotNull);
    repo.failWrite = false;
    expect(await store.logActivity(ActivityType.walk, 30), 20);
    expect(store.activitySaveError, isNull);
  });

  for (final fail in [false, true]) {
    test(
      'switch accounts during read ignores stale ${fail ? 'error' : 'data'}',
      () async {
        final read = Completer<List<ActivityLog>>();
        final repo = FakeActivityRepository();
        final store = SteadyStore(activityRepository: repo);
        addTearDown(store.dispose);
        await store.setActivityOwner('B');
        await store.logActivity(ActivityType.run, 20);
        final bLog = store.logs.single;
        repo.onLoad = (owner) =>
            owner == 'A' ? read.future : Future.value([bLog]);
        final oldLoad = store.setActivityOwner('A');
        await Future<void>.delayed(Duration.zero);
        expect(store.activityLoading, isTrue);
        await store.setActivityOwner('B');
        if (fail) {
          read.completeError(StateError('late read failure'));
        } else {
          read.complete([]);
        }
        await oldLoad;
        expect(store.activityOwnerId, 'B');
        expect(store.logs.single.ownerId, 'B');
        expect(store.points, 20);
        expect(store.activityLoadError, isNull);
        expect(store.activityLoading, isFalse);
      },
    );
  }

  for (final fail in [false, true]) {
    test(
      'switch during write ignores stale ${fail ? 'failure' : 'success'}',
      () async {
        final write = Completer<void>();
        final repo = FakeActivityRepository()..failWrite = fail;
        repo.onInsert = (_) => write.future;
        final store = SteadyStore(activityRepository: repo);
        addTearDown(store.dispose);
        await store.setActivityOwner('A');
        final saving = store.logActivity(ActivityType.walk, 30);
        final loading = store.setActivityOwner('B');
        write.complete();
        expect(await saving, isNull);
        await loading;
        expect(store.logs, isEmpty);
        expect(store.points, 0);
        expect(store.activitySaveError, isNull);
        expect(store.activitySaving, isFalse);
        await store.setActivityOwner('A');
        expect(store.logs.length, fail ? 0 : 1);
      },
    );
  }

  test('rapid saves write once and award only after commit', () async {
    final write = Completer<void>();
    final repo = FakeActivityRepository()..onInsert = (_) => write.future;
    final store = SteadyStore(activityRepository: repo);
    addTearDown(store.dispose);
    await store.setActivityOwner('A');
    final saving = store.logActivity(ActivityType.walk, 30);
    expect(store.activitySaving, isTrue);
    expect(store.points, 0);
    expect(store.checkedInToday, isFalse);
    expect(await store.logActivity(ActivityType.walk, 30), isNull);
    expect(repo.writes, 1);
    write.complete();
    expect(await saving, 20);
    expect(store.logs, hasLength(1));
  });

  test(
    'sign out and back in while write is pending reads committed history',
    () async {
      final write = Completer<void>();
      final repo = FakeActivityRepository()..onInsert = (_) => write.future;
      final store = SteadyStore(activityRepository: repo);
      addTearDown(store.dispose);
      await store.setActivityOwner('A');
      final saving = store.logActivity(ActivityType.walk, 30);
      await store.setActivityOwner(null);
      final restoring = store.setActivityOwner('A');
      write.complete();
      expect(await saving, isNull);
      await restoring;
      expect(store.logs, hasLength(1));
      expect(store.points, 20);
    },
  );
}
