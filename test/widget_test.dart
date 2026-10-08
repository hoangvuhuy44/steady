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
      expect(find.text('Đăng nhập'), findsWidgets);
      expect(find.byType(NavigationBar), findsNothing);
      expect(
        tester
            .widget<FilledButton>(find.byKey(const ValueKey('auth-submit')))
            .onPressed,
        isNotNull,
      );
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
      await tester.pumpWidget(const SteadyApp(requireAuthentication: false));
      await tester.pumpAndSettle();
      expect(find.text('Hôm nay'), findsOneWidget);
      tester.platformDispatcher.localesTestValue = const [Locale('fr')];
      await tester.pumpAndSettle();
      expect(find.text('Today'), findsOneWidget);
    },
  );

  testWidgets('existing validation messages switch language with the form', (
    tester,
  ) async {
    await tester.pumpWidget(
      const SteadyApp(
        requireAuthentication: false,
        initialLocale: Locale('en'),
      ),
    );
    await tester.tap(find.text('Meals'));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const ValueKey('meal-next')));
    expect(find.text('Enter a value from 1 to 120'), findsOneWidget);
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await setLanguage(tester, 'Tiếng Việt');
    await tester.tap(find.text('Bữa ăn'));
    await tester.pumpAndSettle();
    expect(find.text('Nhập giá trị từ 1 đến 120'), findsOneWidget);
    expect(find.text('Enter a value from 1 to 120'), findsNothing);
  });

  testWidgets('Meals draft survives tab changes and language changes', (
    tester,
  ) async {
    await tester.pumpWidget(
      const SteadyApp(
        requireAuthentication: false,
        initialLocale: Locale('en'),
      ),
    );
    await tester.tap(find.text('Meals'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('meal-age')), '32');
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await setLanguage(tester, 'Tiếng Việt');
    expect(find.text('Ngôn ngữ'), findsWidgets);
    await tester.tap(find.text('Bữa ăn'));
    await tester.pumpAndSettle();
    expect(find.text('Bữa ăn dễ dàng hơn'), findsOneWidget);
    expect(find.text('32'), findsOneWidget);
    expect(
      (await SharedPreferences.getInstance()).getString(
        LanguagePreferences.key,
      ),
      'vi',
    );
    await tester.tap(find.text('Hồ sơ').last);
    await tester.pumpAndSettle();
    await setLanguage(tester, 'English');
    await tester.tap(find.text('Meals'));
    await tester.pumpAndSettle();
    expect(find.text('32'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'three-step form validates, creates a plan and preserves data on cancelled edits',
    (tester) async {
      final store = SteadyStore();
      addTearDown(store.dispose);
      await tester.pumpWidget(
        SteadyApp(
          requireAuthentication: false,
          store: store,
          initialLocale: const Locale('en'),
        ),
      );
      await tester.tap(find.text('Meals'));
      await tester.pumpAndSettle();
      await tapVisible(tester, find.byKey(const ValueKey('meal-next')));
      expect(store.nutritionProfile, isNull);
      expect(find.text('Enter a value from 1 to 120'), findsOneWidget);
      await tester.enterText(find.byKey(const ValueKey('meal-age')), '32');
      await tester.enterText(find.byKey(const ValueKey('meal-height')), '170');
      await tester.enterText(find.byKey(const ValueKey('meal-weight')), '65,5');
      await tapVisible(tester, find.byKey(const ValueKey('meal-next')));
      expect(find.text('Step 2 of 3'), findsOneWidget);
      await tapVisible(tester, find.byKey(const ValueKey('meal-next')));
      await tapVisible(tester, find.byKey(const ValueKey('meal-next')));
      expect(
        find.text('Please agree to use your details for this meal plan.'),
        findsOneWidget,
      );
      await tapVisible(tester, find.byKey(const ValueKey('meal-consent')));
      await tapVisible(tester, find.byKey(const ValueKey('meal-next')));
      expect(store.mealPlan, hasLength(7));
      expect(store.nutritionProfile!.weight, 65.5);
      expect(find.text('Your 7-day plan'), findsOneWidget);
      await tapVisible(tester, find.text('Edit preferences'));
      await tester.enterText(find.byKey(const ValueKey('meal-age')), '45');
      await tapVisible(tester, find.text('Cancel'));
      expect(store.nutritionProfile!.age, 32);
      await tapVisible(tester, find.text('Edit preferences'));
      expect(find.text('32'), findsOneWidget);
      expect(find.text('45'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('blood pressure pair validation prevents advancing', (
    tester,
  ) async {
    final store = SteadyStore()..setNutritionProfile(sampleProfile());
    addTearDown(store.dispose);
    await tester.pumpWidget(
      SteadyApp(
        requireAuthentication: false,
        store: store,
        initialLocale: const Locale('vi'),
      ),
    );
    await tester.tap(find.text('Bữa ăn'));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Chỉnh sửa thông tin'));
    await tapVisible(tester, find.byKey(const ValueKey('meal-next')));
    await tapVisible(tester, find.text('Thêm huyết áp hoặc xét nghiệm'));
    await tester.enterText(find.byKey(const ValueKey('meal-sys')), '120');
    await tapVisible(tester, find.byKey(const ValueKey('meal-next')));
    expect(find.text('Bước 2/3'), findsOneWidget);
    expect(
      find.text('Nhập cả hai chỉ số huyết áp hoặc để trống cả hai.'),
      findsWidgets,
    );
    await tester.enterText(find.byKey(const ValueKey('meal-dia')), '80');
    await tapVisible(tester, find.byKey(const ValueKey('meal-next')));
    expect(find.text('Bước 3/3'), findsOneWidget);
  });

  testWidgets(
    'plan swaps, grocery checklist, locale switch and confirmed delete work',
    (tester) async {
      final store = SteadyStore()..setNutritionProfile(sampleProfile());
      addTearDown(store.dispose);
      await tester.pumpWidget(
        SteadyApp(
          requireAuthentication: false,
          store: store,
          initialLocale: const Locale('en'),
        ),
      );
      await tester.tap(find.text('Meals'));
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
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      await setLanguage(tester, 'Tiếng Việt');
      await tester.tap(find.text('Bữa ăn'));
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
      expect(find.text('Bước 1/3'), findsOneWidget);
      expect(find.text('32'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('empty and unsupported plan states provide recovery actions', (
    tester,
  ) async {
    final store = SteadyStore()
      ..setNutritionProfile(sampleProfile(budget: 10000));
    addTearDown(store.dispose);
    await tester.pumpWidget(
      SteadyApp(
        requireAuthentication: false,
        store: store,
        initialLocale: const Locale('en'),
      ),
    );
    await tester.tap(find.text('Meals'));
    await tester.pumpAndSettle();
    expect(find.text('No matching plan yet'), findsOneWidget);
    store.setNutritionProfile(sampleProfile(age: 17));
    await tester.pumpAndSettle();
    expect(find.text('A specialist plan is a better fit'), findsOneWidget);
    expect(find.text('Edit preferences'), findsWidgets);
  });

  for (final code in ['en', 'vi']) {
    testWidgets(
      'all tabs and Meals plan fit a narrow screen with large text ($code)',
      (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        tester.platformDispatcher.textScaleFactorTestValue = 1.6;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final store = SteadyStore()..setNutritionProfile(sampleProfile());
        addTearDown(store.dispose);
        await tester.pumpWidget(
          SteadyApp(
            requireAuthentication: false,
            store: store,
            initialLocale: Locale(code),
          ),
        );
        for (var i = 0; i < 5; i++) {
          await tester.tap(find.byType(NavigationDestination).at(i));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: 'Tab $i in $code');
        }
      },
    );
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
