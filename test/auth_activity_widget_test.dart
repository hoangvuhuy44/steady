import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steady/app/steady_app.dart';
import 'package:steady/models/activity_type.dart';
import 'package:steady/state/steady_store.dart';

import 'auth_screening_widget_test.dart' show FakeAuth;
import 'helpers/fake_activity_repository.dart';

void main() {
  testWidgets(
    'auth restoration, account changes and re-login restore owned history',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final repo = FakeActivityRepository();
      final store = SteadyStore(activityRepository: repo);
      final auth = FakeAuth()..login('A');
      addTearDown(store.dispose);
      addTearDown(auth.dispose);
      final instant = DateTime.now();
      repo.saved.add(
        ActivityLog(
          id: 'A-log',
          ownerId: 'A',
          type: ActivityType.walk,
          minutes: 30,
          createdAt: instant.toUtc(),
          localDate: ActivityLog.dateKey(instant),
        ),
      );
      await tester.pumpWidget(
        SteadyApp(auth: auth, store: store, initialLocale: const Locale('en')),
      );
      await tester.pumpAndSettle();
      expect(store.activityOwnerId, 'A');
      expect(store.points, 20);
      expect(store.streak, 1);
      expect(store.screeningRequired, isTrue);
      store.declineScreening();
      await tester.pumpAndSettle();
      auth.refresh();
      await tester.pumpAndSettle();
      expect(store.screeningRequired, isFalse);
      expect(store.points, 20);
      auth.login('B');
      await tester.pumpAndSettle();
      expect(store.activityOwnerId, 'B');
      expect(store.logs, isEmpty);
      expect(store.screeningRequired, isTrue);
      await store.logActivity(ActivityType.run, 40);
      await auth.signOut();
      await tester.pumpAndSettle();
      expect(store.activityOwnerId, 'guest:test-device');
      expect(store.logs, isEmpty);
      expect(store.points, 0);
      await store.logActivity(ActivityType.swim, 25);
      expect(store.points, 20);
      auth.login('A');
      await tester.pumpAndSettle();
      expect(store.logs.single.id, 'A-log');
      expect(store.points, 20);
      auth.login('B');
      await tester.pumpAndSettle();
      expect(store.logs.single.type, ActivityType.run);
      expect(store.points, 20);
      await auth.signOut();
      await tester.pumpAndSettle();
      expect(store.logs.single.type, ActivityType.swim);
      expect(store.logs.single.ownerId, 'guest:test-device');
    },
  );
}
