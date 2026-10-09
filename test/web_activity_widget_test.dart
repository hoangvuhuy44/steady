import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steady/app/steady_app.dart';
import 'package:steady/models/activity_type.dart';
import 'package:steady/state/steady_store.dart';

void main() {
  testWidgets('web guest can save and restore activity after app remount', (
    tester,
  ) async {
    var store = SteadyStore();
    await tester.runAsync(() => store.setActivityUser(null));
    expect(store.activityLoadError, isNull);
    expect(store.canLogActivity, isTrue);
    final owner = store.activityOwnerId;
    final count = store.logs.length;
    final points = store.points;
    final earned = store.checkedInToday ? 5 : 20;
    await tester.pumpWidget(
      SteadyApp(store: store, initialLocale: const Locale('en')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(NavigationDestination).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Run'));
    tester.widget<Slider>(find.byType(Slider)).onChanged!(60);
    await tester.pump();
    final save = find.byKey(const ValueKey('activity-save'));
    await tester.ensureVisible(save);
    expect(tester.widget<FilledButton>(save).onPressed, isNotNull);
    await tester.runAsync(() async {
      await tester.tap(save);
    });
    await tester.pumpAndSettle();
    expect(store.activitySaveError, isNull);
    expect(store.logs.length, count + 1);
    expect(store.logs.last.type, ActivityType.run);
    expect(store.logs.last.minutes, 60);
    expect(store.points, points + earned);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      0,
    );
    final savedId = store.logs.last.id;
    await tester.pumpWidget(const SizedBox());
    store.dispose();
    store = SteadyStore();
    addTearDown(store.dispose);
    await tester.runAsync(() => store.setActivityUser(null));
    expect(store.activityOwnerId, owner);
    expect(store.logs.length, count + 1);
    expect(store.logs.last.id, savedId);
    expect(store.points, points + earned);
    await tester.pumpWidget(
      SteadyApp(store: store, initialLocale: const Locale('en')),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }, skip: !kIsWeb);
}
