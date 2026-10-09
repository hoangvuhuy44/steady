import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;
import 'package:steady/app/steady_app.dart';
import 'package:steady/l10n/app_localizations.dart';
import 'package:steady/l10n/formatters.dart';
import 'package:steady/main.dart' as app;
import 'package:steady/nutrition/meal_planner.dart';
import 'package:steady/state/language_preferences.dart';
import 'package:steady/state/steady_store.dart';

import 'health_screening_test.dart' show screening;
import 'helpers/fake_activity_repository.dart';
import 'helpers/research_meals_harness.dart';

NutritionProfile sampleProfile({int budget = 120000, int age = 32}) =>
    NutritionProfile(
      age: age,
      height: 170,
      weight: 65,
      goal: 'Ăn uống cân bằng',
      activity: 'Ít vận động',
      cholesterol: 'Chưa biết',
      diet: 'Ăn đa dạng',
      budget: budget,
      minutes: 30,
      exclusions: {},
    );

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      250,
      scrollable: find.byType(Scrollable).hitTestable().first,
    );
  }
  for (var i = 0; i < 3; i++) {
    await Scrollable.ensureVisible(tester.element(finder), alignment: 0.5);
    await tester.pumpAndSettle();
  }
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> setLanguage(WidgetTester tester, String name) async {
  final dropdown = find.byType(DropdownButtonFormField<String>).hitTestable();
  await tapVisible(tester, dropdown);
  await tester.tap(find.text(name).last);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  testWidgets('startup restores saved language', (tester) async {
    SharedPreferences.setMockInitialValues({LanguagePreferences.key: 'vi'});
    await tester.runAsync(app.main);
    try {
      await tester.pumpAndSettle();
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        0,
      );
      expect(find.byKey(const ValueKey('auth-submit')), findsNothing);
      expect(find.byKey(const ValueKey('screening-age')), findsNothing);
    } finally {
      // Dispose the real SDK before Flutter checks for pending refresh timers.
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(() => Supabase.instance.dispose());
    }
  });

  testWidgets(
    'device Vietnamese is used and unsupported device language falls back to English',
    (tester) async {
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      tester.platformDispatcher.localesTestValue = const [Locale('vi')];
      await tester.pumpWidget(
        SteadyApp(
          store: SteadyStore(activityRepository: FakeActivityRepository()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Hôm nay'), findsOneWidget);
      tester.platformDispatcher.localesTestValue = const [Locale('fr')];
      await tester.pumpAndSettle();
      expect(find.text('Today'), findsOneWidget);
    },
  );

  testWidgets(
    'Recipes is available to guests while research planning stays paused',
    (tester) async {
      final store = SteadyStore(activityRepository: FakeActivityRepository());
      addTearDown(store.dispose);
      await tester.pumpWidget(
        SteadyApp(store: store, initialLocale: const Locale('en')),
      );
      await tester.pumpAndSettle();
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        0,
      );
      await tester.tap(find.text('Recipes'));
      await tester.pumpAndSettle();
      expect(find.text('Recipe ideas'), findsOneWidget);
      expect(find.byKey(const ValueKey('screening-age')), findsNothing);
      expect(find.byKey(const ValueKey('meals-setup')), findsNothing);
      expect(store.mealPlanningAllowed, isFalse);
      expect(store.nutritionProfile, isNull);
      await tester.tap(find.text('Today'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        0,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'guest check-in survives app remount and profile language change',
    (tester) async {
      final repo = FakeActivityRepository();
      var store = SteadyStore(activityRepository: repo);
      await tester.pumpWidget(
        SteadyApp(store: store, initialLocale: const Locale('en')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(NavigationDestination).at(1));
      await tester.pumpAndSettle();
      await tapVisible(tester, find.byKey(const ValueKey('activity-save')));
      expect(store.logs, hasLength(1));
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        0,
      );
      await tester.tap(find.byType(NavigationDestination).at(4));
      await tester.pumpAndSettle();
      expect(find.text('Guest'), findsOneWidget);
      await setLanguage(tester, 'English');
      await tester.pumpWidget(const SizedBox());
      store.dispose();
      store = SteadyStore(activityRepository: repo);
      addTearDown(store.dispose);
      await tester.pumpWidget(
        SteadyApp(store: store, initialLocale: const Locale('en')),
      );
      await tester.pumpAndSettle();
      expect(store.logs, hasLength(1));
      expect(store.points, 20);
    },
  );

  testWidgets(
    'plan swaps, grocery checklist, locale switch and confirmed delete work',
    (tester) async {
      final store = SteadyStore(activityRepository: FakeActivityRepository())
        ..completeScreening(screening())
        ..setNutritionProfile(sampleProfile());
      addTearDown(store.dispose);
      await tester.pumpWidget(ResearchMealsHarness(store: store));
      await tester.pumpAndSettle();
      final old = store.mealPlan[0][0];
      await tapVisible(tester, find.byKey(const ValueKey('swap-0')));
      final choice = find.byType(ListTile).hitTestable().first;
      await tester.tap(choice);
      await tester.pumpAndSettle();
      expect(store.mealPlan[0][0].id, isNot(old.id));
      await tapVisible(tester, find.text('Shopping list · 7 days'));
      await tester.tap(find.byType(CheckboxListTile).first);
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((w) => w is CheckboxListTile && w.value == true),
        findsOneWidget,
      );
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      final ids = store.mealPlan.expand((d) => d).map((m) => m.id).toList();
      await tester.pumpWidget(
        ResearchMealsHarness(store: store, locale: const Locale('vi')),
      );
      await tester.pumpAndSettle();
      expect(store.mealPlan.expand((d) => d).map((m) => m.id), ids);
      await tapVisible(tester, find.text('Xoá hồ sơ và thực đơn'));
      await tester.tap(find.text('Huỷ'));
      await tester.pumpAndSettle();
      expect(store.nutritionProfile, isNotNull);
      await tapVisible(tester, find.text('Xoá hồ sơ và thực đơn'));
      await tester.tap(find.text('Xoá'));
      await tester.pumpAndSettle();
      expect(store.nutritionProfile, isNull);
      expect(store.mealPlan, isEmpty);
      expect(find.byKey(const ValueKey('meals-setup')), findsOneWidget);
      expect(find.text('32'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  for (final code in ['en', 'vi']) {
    testWidgets('all MVP tabs fit a narrow screen with large text ($code)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.platformDispatcher.textScaleFactorTestValue = 1.6;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final store = SteadyStore(activityRepository: FakeActivityRepository())
        ..completeScreening(screening())
        ..setNutritionProfile(sampleProfile());
      addTearDown(store.dispose);
      await tester.pumpWidget(
        SteadyApp(store: store, initialLocale: Locale(code)),
      );
      for (var i = 0; i < 5; i++) {
        await tester.tap(find.byType(NavigationDestination).at(i));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'Tab $i in $code');
      }
    });
  }

  test(
    'every catalogue meal, recipe and ingredient has both translations',
    () async {
      for (final code in ['en', 'vi']) {
        final l = await AppLocalizations.delegate.load(Locale(code));
        for (final m in meals) {
          expect(l.mealName(m), isNotEmpty);
          expect(l.mealRecipe(m), isNotEmpty);
          expect(l.mealSlot(m.slot), isNotEmpty);
          for (final key in m.ingredients.keys) {
            expect(l.ingredient(key), isNotEmpty);
          }
        }
      }
    },
  );

  test(
    'language preference survives reload and device setting removes override',
    () async {
      final preferences = LanguagePreferences();
      expect(await preferences.load(), isNull);
      await preferences.save(const Locale('vi'));
      expect(await LanguagePreferences().load(), const Locale('vi'));
      await preferences.save(null);
      expect(await preferences.load(), isNull);
      SharedPreferences.setMockInitialValues({LanguagePreferences.key: 'fr'});
      expect(await preferences.load(), isNull);
    },
  );
}
