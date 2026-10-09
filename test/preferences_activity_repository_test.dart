import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steady/data/activity_repository.dart';
import 'package:steady/models/activity_type.dart';
import 'package:steady/state/steady_store.dart';

class TestPreferences implements SharedPreferencesAsync {
  final values = <String, String>{};
  // Fault switches live in the mutable fixture map; this implementation stays
  // immutable like SharedPreferencesAsync, while tests can toggle failures.
  final failures = <String, bool>{};
  bool get failRead => failures['read'] ?? false;
  set failRead(bool value) => failures['read'] = value;
  bool get failWrite => failures['write'] ?? false;
  set failWrite(bool value) => failures['write'] = value;

  @override
  Future<Set<String>> getKeys({Set<String>? allowList}) async {
    if (failRead) throw StateError('Storage unavailable');
    return values.keys.where((key) => allowList?.contains(key) ?? true).toSet();
  }

  @override
  Future<String?> getString(String key) async {
    if (failRead) throw StateError('Storage unavailable');
    return values[key];
  }

  @override
  Future<bool> containsKey(String key) async =>
      (await getKeys(allowList: {key})).isNotEmpty;

  @override
  Future<void> setString(String key, String value) async {
    if (failWrite) throw StateError('Storage full');
    values[key] = value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test(
    'reopening retains guest identity, fields and separate account history',
    () async {
      final preferences = TestPreferences();
      var repo = PreferencesActivityRepository(preferences: preferences);
      final guest = await repo.guestOwnerId();
      final instant = DateTime.utc(2026, 10, 1, 18);
      final log = ActivityLog(
        id: 'guest-log',
        ownerId: guest,
        type: ActivityType.mma,
        minutes: 60,
        createdAt: instant,
        localDate: '2026-10-02',
      );
      await repo.insert(log);
      await repo.insert(
        ActivityLog(
          id: 'account-log',
          ownerId: 'A',
          type: ActivityType.run,
          minutes: 20,
          createdAt: instant,
          localDate: '2026-10-01',
        ),
      );
      await repo.close();
      repo = PreferencesActivityRepository(preferences: preferences);
      expect(await repo.guestOwnerId(), guest);
      final restored = (await repo.load(guest)).single;
      expect(restored.id, log.id);
      expect(restored.type, log.type);
      expect(restored.minutes, log.minutes);
      expect(restored.createdAt, instant);
      expect(restored.createdAt.isUtc, isTrue);
      expect(restored.localDate, log.localDate);
      expect((await repo.load('A')).single.id, 'account-log');
      expect(await repo.load('B'), isEmpty);
      await expectLater(repo.insert(log), throwsStateError);
      expect(await repo.load(guest), hasLength(1));
    },
  );

  test(
    'failed writes do not award points; storage retry restores saving',
    () async {
      final preferences = TestPreferences();
      final store = SteadyStore(
        activityRepository: PreferencesActivityRepository(
          preferences: preferences,
        ),
      );
      addTearDown(store.dispose);
      await store.setActivityUser(null);
      preferences.failWrite = true;
      expect(await store.logActivity(ActivityType.walk, 30), isNull);
      expect(store.activitySaveError, isNotNull);
      expect(store.points, 0);
      expect(store.logs, isEmpty);
      preferences.failWrite = false;
      expect(await store.logActivity(ActivityType.walk, 30), 20);
      preferences.failRead = true;
      await store.reloadActivities();
      expect(store.canLogActivity, isFalse);
      expect(store.logs, hasLength(1));
      preferences.failRead = false;
      await store.reloadActivities();
      expect(store.canLogActivity, isTrue);
      expect(store.logs, hasLength(1));
      expect(store.points, 20);
    },
  );
}
