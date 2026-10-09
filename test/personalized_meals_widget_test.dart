import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steady/nutrition/nutrition_strategy.dart';
import 'package:steady/state/steady_store.dart';

import 'helpers/research_meals_harness.dart';
import 'helpers/fake_activity_repository.dart';
import 'nutrition_strategy_test.dart' show healthProfile;
import 'widget_test.dart' show tapVisible;

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  for (final code in ['vi', 'en']) {
    testWidgets('personalized four-meal plan and edit fit large text ($code)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.6;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final store = SteadyStore(activityRepository: FakeActivityRepository());
      addTearDown(store.dispose);
      await tester.pumpWidget(
        ResearchMealsHarness(store: store, locale: Locale(code)),
      );
      store.completeScreening(
        healthProfile(
          strategy: const NutritionStrategy(
            goal: BodyGoal.muscleGain,
            energy: EnergyStrategy.leanBulk,
            macros: MacroStrategy.highProtein,
            source: FoodSource.vegan,
            timing: MealTiming.fourMeals,
            resistanceSessions: 3,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      expect(store.mealPlan, hasLength(7));
      expect(store.mealPlan.first, hasLength(4));
      expect(tester.takeException(), isNull);
      await tapVisible(tester, find.byKey(const ValueKey('swap-3')));
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip(code == 'vi' ? 'Đóng' : 'Close'));
      await tester.pumpAndSettle();
      final edit = find.text(
        code == 'vi' ? 'Chỉnh sửa thông tin' : 'Edit preferences',
      );
      await tester.scrollUntilVisible(
        edit,
        -300,
        scrollable: find.byType(Scrollable).hitTestable().first,
      );
      await tapVisible(tester, edit);
      expect(store.screeningRequired, isTrue);
      expect(store.mealPlan, isEmpty);
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('screening-bodyFat')),
        250,
        scrollable: find.byType(Scrollable).hitTestable().first,
      );
      expect(find.byKey(const ValueKey('screening-bodyFat')), findsOneWidget);
      expect(find.text('20.0'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
