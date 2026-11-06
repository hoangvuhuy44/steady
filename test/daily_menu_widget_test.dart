import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steady/app/steady_app.dart';
import 'package:steady/l10n/app_localizations.dart';
import 'package:steady/personalization/daily_menu_screen.dart';
import 'package:steady/personalization/food_questionnaire.dart';
import 'package:steady/personalization/menu_controller.dart';
import 'package:steady/personalization/food_profile.dart';
import 'package:steady/state/steady_store.dart';
import 'package:steady/theme/steady_theme.dart';

import 'daily_menu_test.dart' show MemoryMenuRepository;
import 'helpers/fake_activity_repository.dart';
import 'auth_screening_widget_test.dart' show FakeAuth;
import 'widget_test.dart' as test_utils;

Future<void> foodTap(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    final scroll = tester.state<ScrollableState>(
      find.byType(Scrollable).hitTestable().first,
    );
    scroll.position.jumpTo(0);
    await tester.pumpAndSettle();
  }
  await test_utils.tapVisible(tester, finder);
}

void main() {
  for (final code in ['vi', 'en']) {
    testWidgets(
      'questionnaire, 3 meals, swap and allergy edit at 320px/200% ($code)',
      (tester) async {
        tester.view.resetPhysicalSize();
        tester.view.physicalSize = const Size(320, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final controller = DailyMenuController(
          repository: MemoryMenuRepository(),
        );
        await controller.refresh();
        await tester.pumpWidget(
          MaterialApp(
            theme: SteadyTheme.light(),
            locale: Locale(code),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(2)),
              child: child!,
            ),
            home: DailyMenuScreen(controller: controller),
          ),
        );
        await tester.pumpAndSettle();
        await foodTap(tester, find.byKey(const ValueKey('food-profile-edit')));
        expect(find.byType(FoodQuestionnaire), findsOneWidget);
        await foodTap(tester, find.byKey(const ValueKey('food-next')));
        await foodTap(tester, find.byKey(const ValueKey('food-form-error')));
        await foodTap(tester, find.byKey(const ValueKey('food-allergy-none')));
        for (var i = 0; i < 4; i++) {
          await foodTap(tester, find.byKey(const ValueKey('food-next')));
        }
        await foodTap(tester, find.byKey(const ValueKey('food-next')));
        expect(find.byType(FoodQuestionnaire), findsNothing);
        expect(controller.menu.every((r) => r != null), isTrue);
        final breakfast = controller.menu[0]!.id;
        final dinner = controller.menu[2]!.id;
        final lunch = controller.menu[1]!.id;
        for (var i = 0; i < 3; i++) {
          await foodTap(tester, find.byKey(ValueKey('daily-slot-$i')));
          expect(tester.takeException(), isNull);
        }
        await foodTap(tester, find.byKey(const ValueKey('daily-swap-1')));
        expect(controller.menu[0]!.id, breakfast);
        expect(controller.menu[2]!.id, dinner);
        expect(controller.menu[1]!.id, isNot(lunch));
        await foodTap(tester, find.byKey(const ValueKey('food-profile-edit')));
        await foodTap(tester, find.byKey(const ValueKey('food-allergy-soy')));
        for (var i = 0; i < 5; i++) {
          await foodTap(tester, find.byKey(const ValueKey('food-next')));
        }
        expect(controller.profile!.allergies, {'soy'});
        expect(controller.menu, [null, null, null]);
        await foodTap(
          tester,
          find.byKey(const ValueKey('daily-menu-shortage')),
        );
        for (var i = 0; i < 3; i++) {
          await foodTap(tester, find.byKey(ValueKey('daily-slot-$i')));
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        controller.dispose();
      },
    );
  }

  testWidgets(
    'saved profile opens daily tab; account switch closes private routes',
    (tester) async {
      final repo = MemoryMenuRepository();
      final initial = DailyMenuController(repository: repo);
      await initial.refresh();
      await initial.saveProfile(FoodProfile());
      initial.dispose();
      final store = SteadyStore(activityRepository: FakeActivityRepository());
      final auth = FakeAuth();
      addTearDown(store.dispose);
      addTearDown(auth.dispose);
      await tester.pumpWidget(
        SteadyApp(
          store: store,
          auth: auth,
          initialLocale: const Locale('en'),
          menuRepository: repo,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(NavigationDestination).at(2));
      await tester.pumpAndSettle();
      expect(find.byType(DailyMenuScreen), findsOneWidget);
      await foodTap(tester, find.byKey(const ValueKey('food-profile-edit')));
      expect(find.byType(FoodQuestionnaire), findsOneWidget);
      auth.login('new');
      await tester.pumpAndSettle();
      expect(find.byType(FoodQuestionnaire), findsNothing);
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        2,
      );
      await tester.pumpWidget(const SizedBox());
    },
  );
}
