import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steady/app/steady_app.dart';
import 'package:steady/l10n/app_localizations.dart';
import 'package:steady/l10n/formatters.dart';
import 'package:steady/nutrition/meal_planner.dart';
import 'package:steady/screens/recipes_screen.dart';
import 'package:steady/state/steady_store.dart';

import 'auth_screening_widget_test.dart' show FakeAuth, openSignIn;
import 'health_screening_test.dart' show screening;
import 'helpers/fake_activity_repository.dart';
import 'widget_test.dart' show tapVisible, setLanguage;

Future<void> openRecipes(WidgetTester tester) async {
  await tester.tap(find.byType(NavigationDestination).at(2));
  await tester.pumpAndSettle();
}

Future<void> expectCount(WidgetTester tester, int count, String code) async {
  final finder = find.byKey(const ValueKey('recipe-result-count'));
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      300,
      scrollable: find.byType(Scrollable).hitTestable().first,
    );
    await tester.pumpAndSettle();
  }
  expect(
    tester.widget<Text>(find.byKey(const ValueKey('recipe-result-count'))).data,
    code == 'vi' ? '$count công thức' : '$count recipes',
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('guest catalogue and detail require no screening or plan', (
    tester,
  ) async {
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
    await openRecipes(tester);
    await expectCount(tester, meals.length, 'en');
    expect(find.text('Recipe ideas'), findsOneWidget);
    expect(find.text('Breakfast · About 10 min'), findsOneWidget);
    expect(store.canLogActivity, isTrue);
    expect(store.mealPlanningAllowed, isFalse);
    expect(store.healthScreening, isNull);
    expect(store.nutritionProfile, isNull);
    expect(store.mealPlan, isEmpty);
    for (final key in ['meals-setup', 'screening-age', 'swap-0']) {
      expect(find.byKey(ValueKey(key)), findsNothing);
    }
    await tapVisible(tester, find.byKey(const ValueKey('recipe-card-oats')));
    final l = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.byType(RecipeDetailScreen), findsOneWidget);
    expect(find.text('Ingredients'), findsOneWidget);
    expect(find.text('Oats: 70 g'), findsOneWidget);
    expect(find.text('Banana: 100 g'), findsOneWidget);
    expect(find.text(l.recipesSampleQuantities), findsOneWidget);
    await tapVisible(tester, find.text(l.mealRecipe(meals.first)));
    expect(find.text('Preparation'), findsOneWidget);
    expect(find.textContaining('kcal'), findsNothing);
    expect(find.textContaining('₫'), findsNothing);
    expect(find.text('Protein'), findsNothing);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await expectCount(tester, meals.length, 'en');
  });

  for (final code in ['en', 'vi']) {
    testWidgets('combined filters, empty results and explicit reset ($code)', (
      tester,
    ) async {
      final store = SteadyStore(activityRepository: FakeActivityRepository());
      addTearDown(store.dispose);
      await tester.pumpWidget(
        SteadyApp(store: store, initialLocale: Locale(code)),
      );
      await tester.pumpAndSettle();
      await openRecipes(tester);
      final l = await AppLocalizations.delegate.load(Locale(code));
      await tapVisible(tester, find.text(l.recipesFilters));
      expect(find.text(l.recipesAllergyLimit), findsOneWidget);
      await tapVisible(tester, find.byKey(const ValueKey('recipe-slot-Sáng')));
      await tapVisible(tester, find.byKey(const ValueKey('recipe-time-20')));
      await tapVisible(
        tester,
        find.byKey(const ValueKey('recipe-avoid-label-soy')),
      );
      await tapVisible(
        tester,
        find.byKey(const ValueKey('recipe-avoid-label-egg')),
      );
      await expectCount(tester, 1, code);
      await tapVisible(
        tester,
        find.byKey(const ValueKey('recipe-avoid-ingredient-Gạo lứt')),
      );
      await expectCount(tester, 0, code);
      expect(
        tester
            .widget<ChoiceChip>(find.byKey(const ValueKey('recipe-slot-Sáng')))
            .selected,
        isTrue,
      );
      expect(
        tester
            .widget<ChoiceChip>(find.byKey(const ValueKey('recipe-time-20')))
            .selected,
        isTrue,
      );
      expect(
        tester
            .widget<FilterChip>(
              find.byKey(const ValueKey('recipe-avoid-label-soy')),
            )
            .selected,
        isTrue,
      );
      await tapVisible(tester, find.text(l.recipesFilters));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('recipe-empty')), findsOneWidget);
      expect(find.text(l.recipesEmptyHelp), findsOneWidget);
      await tapVisible(
        tester,
        find.byKey(const ValueKey('recipe-empty-clear')),
      );
      await expectCount(tester, meals.length, code);
      expect(find.byKey(const ValueKey('recipe-empty')), findsNothing);
      await tapVisible(tester, find.text(l.recipesFilters));
      await tapVisible(tester, find.byKey(const ValueKey('recipe-slot-Trưa')));
      await tapVisible(tester, find.byKey(const ValueKey('recipe-time-10')));
      await expectCount(tester, 0, code);
      await tapVisible(
        tester,
        find.byKey(const ValueKey('recipe-clear-filters')),
      );
      await expectCount(tester, meals.length, code);
      expect(tester.takeException(), isNull);
    });

    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      testWidgets(
        'phone catalogue, filters and details at 200% text ($code, $platform)',
        (tester) async {
          tester.view.physicalSize = const Size(320, 760);
          tester.view.devicePixelRatio = 1;
          tester.platformDispatcher.textScaleFactorTestValue = 2;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          final l = await AppLocalizations.delegate.load(Locale(code));
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(platform: platform),
              locale: Locale(code),
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              home: const Scaffold(body: SafeArea(child: RecipesScreen())),
            ),
          );
          await tester.pumpAndSettle();
          await tapVisible(tester, find.text(l.recipesFilters));
          await tapVisible(
            tester,
            find.byKey(const ValueKey('recipe-avoid-label-shellfish')),
          );
          await tapVisible(
            tester,
            find.byKey(
              const ValueKey(
                'recipe-avoid-ingredient-Sữa đậu nành không đường',
              ),
            ),
          );
          await tapVisible(
            tester,
            find.byKey(const ValueKey('recipe-clear-filters')),
          );
          await tapVisible(tester, find.text(l.recipesFilters));
          for (final id in ['oats', 'ketoTofuDinner']) {
            await tapVisible(tester, find.byKey(ValueKey('recipe-card-$id')));
            final meal = meals.firstWhere((meal) => meal.id == id);
            await tapVisible(tester, find.text(l.mealRecipe(meal)));
            expect(tester.takeException(), isNull);
            await tester.tap(find.byType(BackButton));
            await tester.pumpAndSettle();
          }
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets(
    'login preserves current tab; recipe access leaves research rules enforced',
    (tester) async {
      final store = SteadyStore(activityRepository: FakeActivityRepository());
      final auth = FakeAuth();
      addTearDown(store.dispose);
      addTearDown(auth.dispose);
      await tester.pumpWidget(
        SteadyApp(store: store, auth: auth, initialLocale: const Locale('en')),
      );
      await tester.pumpAndSettle();
      await openRecipes(tester);
      auth.login('member');
      await tester.pumpAndSettle();
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        2,
      );
      await expectCount(tester, meals.length, 'en');
      expect(store.mealPlanningAllowed, isFalse);
      expect(store.mealPlan, isEmpty);
      store.completeScreening(screening());
      await tester.pumpAndSettle();
      await auth.signOut();
      await tester.pumpAndSettle();
      expect(store.mealPlanningAllowed, isFalse);
      expect(store.screeningRequired, isTrue);
      await expectCount(tester, meals.length, 'en');
      await openSignIn(tester);
      await tester.enterText(
        find.byKey(const ValueKey('auth-email')),
        'first@example.com',
      );
      await tester.enterText(
        find.byKey(const ValueKey('auth-password')),
        'password',
      );
      await tapVisible(tester, find.byKey(const ValueKey('auth-submit')));
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        4,
      );
      expect(find.byKey(const ValueKey('screening-age')), findsNothing);
    },
  );

  testWidgets('locale switch retains recipe filters', (tester) async {
    final store = SteadyStore(activityRepository: FakeActivityRepository());
    addTearDown(store.dispose);
    await tester.pumpWidget(
      SteadyApp(store: store, initialLocale: const Locale('en')),
    );
    await tester.pumpAndSettle();
    await openRecipes(tester);
    await tapVisible(tester, find.text('Recipe filters'));
    await tapVisible(tester, find.byKey(const ValueKey('recipe-slot-Tối')));
    await tapVisible(tester, find.byKey(const ValueKey('recipe-time-20')));
    await expectCount(tester, 3, 'en');
    await tester.tap(find.byType(NavigationDestination).at(4));
    await tester.pumpAndSettle();
    await setLanguage(tester, 'Tiếng Việt');
    await openRecipes(tester);
    expect(find.text('Món ăn'), findsOneWidget);
    await expectCount(tester, 3, 'vi');
  });
}
