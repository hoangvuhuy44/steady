import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steady/l10n/app_localizations.dart';
import 'package:steady/models/activity_type.dart';
import 'package:steady/screens/check_in_screen.dart';
import 'package:steady/state/steady_store.dart';

import 'helpers/fake_activity_repository.dart';

void main() {
  Future<void> showCheckIn(
    WidgetTester tester,
    SteadyStore store,
    VoidCallback onSaved,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: CheckInScreen(store: store, onSaved: onSaved),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets(
    'save locks immediately; failure keeps form; retry succeeds after commit',
    (tester) async {
      final pending = Completer<void>();
      final repo = FakeActivityRepository()..onInsert = (_) => pending.future;
      final store = SteadyStore(activityRepository: repo);
      addTearDown(store.dispose);
      await store.setActivityOwner('A');
      var saved = 0;
      await showCheckIn(tester, store, () => saved++);
      await tester.tap(find.text('Run'));
      await tester.pump();
      tester.widget<Slider>(find.byType(Slider)).onChanged!(55);
      await tester.pump();
      final save = find.byKey(const ValueKey('activity-save'));
      await tester.ensureVisible(save);
      final callback = tester.widget<FilledButton>(save).onPressed!;
      callback();
      callback();
      await tester.pump();
      expect(tester.widget<FilledButton>(save).onPressed, isNull);
      expect(saved, 0);
      expect(store.points, 0);
      expect(repo.writes, 1);
      expect(find.byType(SnackBar), findsNothing);
      pending.completeError(StateError('disk full'));
      await tester.pumpAndSettle();
      expect(saved, 0);
      expect(find.byKey(const ValueKey('activity-save-error')), findsOneWidget);
      expect(tester.widget<Slider>(find.byType(Slider)).value, 55);
      expect(
        tester
            .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Run'))
            .selected,
        isTrue,
      );
      repo.onInsert = null;
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(saved, 1);
      expect(store.logs.single.type, ActivityType.run);
      expect(store.logs.single.minutes, 55);
      expect(store.points, 20);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Run logged · 55 minutes'), findsOneWidget);
    },
  );

  testWidgets('load error has retry and prevents saving', (tester) async {
    final repo = FakeActivityRepository()..failRead = true;
    final store = SteadyStore(activityRepository: repo);
    addTearDown(store.dispose);
    await store.setActivityOwner('A');
    await showCheckIn(tester, store, () {});
    expect(find.byKey(const ValueKey('activity-load-error')), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.byKey(const ValueKey('activity-save')))
          .onPressed,
      isNull,
    );
    repo.failRead = false;
    await tester.tap(find.byKey(const ValueKey('activity-retry')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('activity-load-error')), findsNothing);
    expect(
      tester
          .widget<FilledButton>(find.byKey(const ValueKey('activity-save')))
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('account switch during save cannot trigger success UI', (
    tester,
  ) async {
    final write = Completer<void>();
    final repo = FakeActivityRepository()..onInsert = (_) => write.future;
    final store = SteadyStore(activityRepository: repo);
    addTearDown(store.dispose);
    await store.setActivityOwner('A');
    var saved = 0;
    await showCheckIn(tester, store, () => saved++);
    final save = find.byKey(const ValueKey('activity-save'));
    await tester.ensureVisible(save);
    await tester.tap(save);
    final loading = store.setActivityOwner('B');
    write.complete();
    await loading;
    await tester.pumpAndSettle();
    expect(saved, 0);
    expect(find.byType(SnackBar), findsNothing);
    expect(store.logs, isEmpty);
  });
}
