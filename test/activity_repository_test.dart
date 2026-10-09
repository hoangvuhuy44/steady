import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:steady/data/activity_repository.dart';
import 'package:steady/models/activity_type.dart';
import 'package:steady/state/steady_store.dart';

void main() {
  sqfliteFfiInit();
  late Directory directory;
  late SqliteActivityRepository repo;
  SqliteActivityRepository openRepository() => SqliteActivityRepository(
    factory: databaseFactoryFfi,
    databasePath: path.join(directory.path, 'activities.db'),
  );

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('steady_activity_test_');
    repo = openRepository();
  });
  tearDown(() async {
    await repo.close();
    await directory.delete(recursive: true);
  });

  test(
    'guest identity and history persist independently of accounts',
    () async {
      final guest = await repo.guestOwnerId();
      expect(guest, startsWith('guest:'));
      expect(await repo.guestOwnerId(), guest);
      var store = SteadyStore(activityRepository: repo);
      await store.setActivityUser(null);
      expect(store.activityOwnerId, guest);
      expect(await store.logActivity(ActivityType.walk, 30), 20);
      await store.setActivityUser('A');
      expect(store.logs, isEmpty);
      await store.logActivity(ActivityType.run, 20);
      await store.setActivityUser('B');
      expect(store.logs, isEmpty);
      store.dispose();
      await repo.close();
      repo = openRepository();
      expect(await repo.guestOwnerId(), guest);
      store = SteadyStore(activityRepository: repo);
      addTearDown(store.dispose);
      await store.setActivityUser(null);
      expect(store.logs.single.type, ActivityType.walk);
      await store.setActivityUser('A');
      expect(store.logs.single.type, ActivityType.run);
      await store.setActivityUser(null);
      expect(store.logs.single.ownerId, guest);
      expect(await repo.load('B'), isEmpty);
    },
  );

  test(
    'v1 migration keeps existing account logs and adds guest identity',
    () async {
      final db = await databaseFactoryFfi.openDatabase(
        path.join(directory.path, 'activities.db'),
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, _) async {
            await db.execute(
              'CREATE TABLE activity_logs ('
              'id TEXT PRIMARY KEY, owner_id TEXT, activity_type TEXT, '
              'minutes INTEGER, created_at_utc INTEGER, local_date TEXT)',
            );
            await db.insert('activity_logs', {
              'id': 'old-account-log',
              'owner_id': 'A',
              'activity_type': 'walk',
              'minutes': 30,
              'created_at_utc': 0,
              'local_date': '2026-10-01',
            });
          },
        ),
      );
      await db.close();
      expect((await repo.load('A')).single.id, 'old-account-log');
      expect(await repo.guestOwnerId(), startsWith('guest:'));
      expect(await repo.load(await repo.guestOwnerId()), isEmpty);
      await repo.insert(
        ActivityLog(
          id: 'new-earlier-log',
          ownerId: 'A',
          type: ActivityType.run,
          minutes: 15,
          createdAt: DateTime.fromMicrosecondsSinceEpoch(-1, isUtc: true),
          localDate: '1969-12-31',
        ),
      );
      expect((await repo.load('A')).map((log) => log.id), [
        'new-earlier-log',
        'old-account-log',
      ]);
    },
  );

  test('save, close, reopen preserves every field and isolates A/B', () async {
    final instant = DateTime.utc(2026, 10, 1, 18, 15);
    final log = ActivityLog(
      id: 'activity-A',
      ownerId: 'A',
      type: ActivityType.mma,
      minutes: 45,
      createdAt: instant,
      localDate: '2026-10-02',
    );
    await repo.insert(log);
    await repo.insert(
      ActivityLog(
        id: 'activity-B',
        ownerId: 'B',
        type: ActivityType.run,
        minutes: 20,
        createdAt: instant,
        localDate: '2026-10-01',
      ),
    );
    await repo.close();
    repo = openRepository();
    final restored = (await repo.load('A')).single;
    expect(restored.id, log.id);
    expect(restored.ownerId, 'A');
    expect(restored.type, ActivityType.mma);
    expect(restored.minutes, 45);
    expect(restored.createdAt, instant);
    expect(restored.createdAt.isUtc, isTrue);
    expect(restored.localDate, '2026-10-02');
    expect((await repo.load('B')).single.id, 'activity-B');
    expect(await repo.load("A' OR 1=1 --"), isEmpty);
    final db = await databaseFactoryFfi.openDatabase(
      path.join(directory.path, 'activities.db'),
    );
    final rows = await db.query(
      'activity_logs',
      where: 'id = ?',
      whereArgs: ['activity-A'],
    );
    expect(rows.single['activity_type'], 'mma');
  });

  test(
    'new store restores points/streak; screening and logout keep database',
    () async {
      var now = DateTime(2026, 10, 1, 23, 55);
      var store = SteadyStore(activityRepository: repo, now: () => now);
      await store.setActivityOwner('A');
      await store.logActivity(ActivityType.walk, 30);
      await store.logActivity(ActivityType.run, 20);
      now = DateTime(2026, 10, 2, 0, 5);
      await store.logActivity(ActivityType.swim, 25);
      expect(store.points, 45);
      expect(store.streak, 2);
      store.dispose();
      await repo.close();
      repo = openRepository();
      store = SteadyStore(activityRepository: repo, now: () => now);
      addTearDown(store.dispose);
      await store.setActivityOwner('A');
      expect(store.logs, hasLength(3));
      expect(store.points, 45);
      expect(store.streak, 2);
      expect(store.checkedInToday, isTrue);
      expect(store.activityMetrics.activeDays, 2);
      expect(store.activityMetrics.minutes, 75);
      store.beginSession();
      expect(store.points, 45);
      expect(store.streak, 2);
      await store.setActivityOwner(null);
      expect(store.logs, isEmpty);
      expect(store.points, 0);
      expect(store.streak, 0);
      expect(store.canLogActivity, isFalse);
      await store.setActivityOwner('B');
      expect(store.logs, isEmpty);
      await store.logActivity(ActivityType.gym, 40);
      expect(store.points, 20);
      await store.setActivityOwner('A');
      expect(store.points, 45);
      expect(store.streak, 2);
      await store.setActivityOwner(null);
      await store.setActivityOwner('A');
      expect(store.logs, hasLength(3));
      expect(store.points, 45);
      expect(store.streak, 2);
      expect(store.activityMetrics.activeDays, 2);
      expect(store.activityMetrics.minutes, 75);
    },
  );

  test(
    'stored local calendar date determines points and streak across timezones',
    () async {
      for (final (id, localDate, utc) in [
        ('1', '2026-09-30', DateTime.utc(2026, 10, 1, 3)),
        ('2', '2026-10-01', DateTime.utc(2026, 10, 1, 15)),
        ('3', '2026-10-01', DateTime.utc(2026, 10, 2, 2)),
      ]) {
        await repo.insert(
          ActivityLog(
            id: id,
            ownerId: 'A',
            type: ActivityType.walk,
            minutes: 30,
            createdAt: utc,
            localDate: localDate,
          ),
        );
      }
      final store = SteadyStore(
        activityRepository: repo,
        now: () => DateTime(2026, 10, 1, 23),
      );
      addTearDown(store.dispose);
      await store.setActivityOwner('A');
      expect(store.points, 45);
      expect(store.streak, 2);
      expect(store.checkedInToday, isTrue);
    },
  );

  test('constraint failure does not replace existing history', () async {
    final log = ActivityLog(
      id: '1',
      ownerId: 'A',
      type: ActivityType.walk,
      minutes: 30,
      createdAt: DateTime.utc(2026, 10, 1),
      localDate: '2026-10-01',
    );
    await repo.insert(log);
    await expectLater(repo.insert(log), throwsA(isA<DatabaseException>()));
    expect(await repo.load('A'), hasLength(1));
  });
}
