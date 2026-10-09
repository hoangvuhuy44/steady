import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steady/app/steady_app.dart';
import 'package:steady/l10n/app_localizations.dart';
import 'package:steady/models/activity_type.dart';
import 'package:steady/screens/home_screen.dart';
import 'package:steady/widgets/activity_goal.dart';
import 'package:steady/widgets/consistency_week.dart';
import 'package:steady/widgets/metric_card.dart';
import 'package:steady/state/steady_store.dart';

import 'helpers/fake_activity_repository.dart';

ActivityLog log(String date, {int minutes = 20}) => ActivityLog(
  id: date,
  ownerId: 'guest:test-device',
  type: ActivityType.run,
  minutes: minutes,
  createdAt: DateTime.utc(2020, 1, 1),
  localDate: date,
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final code in ['en', 'vi']) {
    testWidgets('Home and Profile show the same reached 5/7 goal ($code)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(900, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final l = await AppLocalizations.delegate.load(Locale(code));
      final repo = FakeActivityRepository()
        ..saved.addAll([
          for (var day = 3; day <= 7; day++) log('2026-10-0$day'),
          log('2026-10-10', minutes: 200),
        ]);
      final store = SteadyStore(
        now: () => DateTime(2026, 10, 9),
        activityRepository: repo,
      );
      addTearDown(store.dispose);
      await tester.pumpWidget(
        SteadyApp(store: store, initialLocale: Locale(code)),
      );
      await tester.pumpAndSettle();
      expect(find.text(l.noActivity), findsOneWidget);
      expect(find.text(l.anyMovement), findsOneWidget);
      expect(find.text('0 ${l.dayStreak}'), findsOneWidget);
      expect(find.text(l.streakRule), findsOneWidget);
      expect(find.text(l.steadyPoints), findsNothing);
      expect(
        tester
            .widget<MetricCard>(
              find.byKey(const ValueKey('recent-active-days')),
            )
            .value,
        '5/7',
      );
      expect(
        tester
            .widget<MetricCard>(
              find.byKey(const ValueKey('recent-active-minutes')),
            )
            .value,
        '100',
      );
      expect(find.text(l.fiveDays), findsOneWidget);
      final progress =
          '${l.activeDaysProgress(5)} · ${l.activityTargetReached}';
      expect(find.text(progress), findsOneWidget);
      final calendar = tester.widget<ConsistencyWeek>(
        find.byType(ConsistencyWeek),
      );
      expect(calendar.metrics.today, DateTime.utc(2026, 10, 9));
      expect(calendar.metrics.days.map(calendar.metrics.isActiveOn), [
        true,
        true,
        true,
        true,
        true,
        false,
        false,
      ]);
      await tester.tap(find.byType(NavigationDestination).at(4));
      await tester.pumpAndSettle();
      expect(find.text(l.fiveDays), findsOneWidget);
      expect(find.text(progress), findsOneWidget);
      expect(
        tester
            .widget<ActivityGoal>(find.byType(ActivityGoal))
            .metrics
            .targetReached,
        isTrue,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets(
    'today card does not display yesterday, even with a retained streak',
    (tester) async {
      final repo = FakeActivityRepository()..saved.add(log('2026-10-08'));
      final store = SteadyStore(
        now: () => DateTime(2026, 10, 9),
        activityRepository: repo,
      );
      addTearDown(store.dispose);
      await store.setActivityUser(null);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: HomeScreen(store: store, onCheckIn: () {}),
          ),
        ),
      );
      final l = await AppLocalizations.delegate.load(const Locale('en'));
      expect(store.streak, 1);
      expect(find.text(l.noActivity), findsOneWidget);
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('today-activity-detail')))
            .data,
        l.anyMovement,
      );
    },
  );

  testWidgets(
    'midnight and resume refresh Home, metrics and calendar from store clock',
    (tester) async {
      tester.view.physicalSize = const Size(900, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var now = DateTime(2026, 12, 31, 23, 59, 50);
      final repo = FakeActivityRepository()
        ..saved.addAll([
          log('2026-12-25', minutes: 10),
          log('2026-12-31', minutes: 30),
        ]);
      final store = SteadyStore(now: () => now, activityRepository: repo);
      addTearDown(store.dispose);
      await tester.pumpWidget(
        SteadyApp(store: store, initialLocale: const Locale('en')),
      );
      await tester.pumpAndSettle();
      final l = await AppLocalizations.delegate.load(const Locale('en'));
      expect(find.text(l.checkInComplete), findsOneWidget);
      expect(
        tester
            .widget<MetricCard>(
              find.byKey(const ValueKey('recent-active-minutes')),
            )
            .value,
        '40',
      );

      now = DateTime(2027, 1, 1);
      await tester.pump(const Duration(seconds: 10));
      await tester.pumpAndSettle();
      expect(find.text(l.noActivity), findsOneWidget);
      expect(find.text('1 ${l.dayStreak}'), findsOneWidget);
      expect(
        tester
            .widget<MetricCard>(
              find.byKey(const ValueKey('recent-active-days')),
            )
            .value,
        '1/7',
      );
      expect(
        tester
            .widget<MetricCard>(
              find.byKey(const ValueKey('recent-active-minutes')),
            )
            .value,
        '30',
      );
      expect(
        tester
            .widget<ConsistencyWeek>(find.byType(ConsistencyWeek))
            .metrics
            .today,
        DateTime.utc(2027, 1, 1),
      );
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('today-activity-detail')))
            .data,
        l.anyMovement,
      );

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      now = DateTime(2027, 1, 8, 23, 59, 55);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(find.text('0 ${l.dayStreak}'), findsOneWidget);
      expect(
        tester
            .widget<MetricCard>(
              find.byKey(const ValueKey('recent-active-days')),
            )
            .value,
        '0/7',
      );
      expect(
        tester
            .widget<MetricCard>(
              find.byKey(const ValueKey('recent-active-minutes')),
            )
            .value,
        '0',
      );
      expect(
        tester
            .widget<ConsistencyWeek>(find.byType(ConsistencyWeek))
            .metrics
            .today,
        DateTime.utc(2027, 1, 8),
      );

      // Resuming also schedules the next midnight using the store's clock.
      now = DateTime(2027, 1, 9);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<ConsistencyWeek>(find.byType(ConsistencyWeek))
            .metrics
            .today,
        DateTime.utc(2027, 1, 9),
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
