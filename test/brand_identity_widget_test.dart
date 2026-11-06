import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steady/app/steady_app.dart';
import 'package:steady/screens/screening_screen.dart';
import 'package:steady/screens/sign_in_screen.dart';
import 'package:steady/state/steady_store.dart';
import 'package:steady/theme/steady_colors.dart';
import 'package:steady/theme/steady_motion.dart';
import 'package:steady/theme/steady_theme.dart';
import 'package:steady/widgets/brand/steady_progress.dart';

import 'helpers/brand_fonts.dart';
import 'helpers/fake_activity_repository.dart';
import 'auth_screening_widget_test.dart' show FakeAuth, openSignIn;
import 'widget_test.dart' show tapVisible;

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('reading text and primary actions satisfy AA contrast', () {
    double contrast(Color a, Color b) {
      final luminances = [a.computeLuminance(), b.computeLuminance()]..sort();
      return (luminances.last + 0.05) / (luminances.first + 0.05);
    }

    for (final background in [SteadyColors.white, SteadyColors.softCloud]) {
      expect(contrast(SteadyColors.ink, background), greaterThanOrEqualTo(4.5));
      expect(
        contrast(SteadyColors.muted, background),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrast(SteadyColors.deepCoreBlue, background),
        greaterThanOrEqualTo(4.5),
      );
    }
    expect(
      contrast(SteadyColors.white, SteadyColors.deepCoreBlue),
      greaterThanOrEqualTo(4.5),
    );
    for (final accent in [
      SteadyColors.freshMint,
      SteadyColors.aquaTeal,
      SteadyColors.flowCyan,
    ]) {
      expect(contrast(SteadyColors.ink, accent), greaterThanOrEqualTo(4.5));
    }
  });

  testWidgets('progress announces actual values and respects reduced motion', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: SteadyTheme.light(),
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Builder(
            builder: (context) {
              expect(SteadyMotion.durationOf(context), Duration.zero);
              return const Scaffold(
                body: Column(
                  children: [
                    SteadyProgressBar(value: 0.6, semanticLabel: '3/5'),
                    SteadyProgressRing(value: 0.6, semanticLabel: '3/5'),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
    final semantics = tester.ensureSemantics();
    await tester.pump();
    expect(
      tester.getSize(find.byType(SteadyProgressBar)).width,
      greaterThanOrEqualTo(200),
    );
    expect(find.bySemanticsLabel('3/5'), findsNWidgets(2));
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.value == '60%',
      ),
      findsNWidgets(2),
    );
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  for (final code in ['vi', 'en']) {
    for (final layout in [
      (320.0, 1.0),
      (320.0, 2.0),
      (390.0, 1.0),
      (1024.0, 2.0),
    ]) {
      testWidgets(
        'branded screens with real fonts ($code, ${layout.$1}px, ${layout.$2}x)',
        (tester) async {
          await loadBrandFonts();
          tester.view.physicalSize = Size(layout.$1, 900);
          tester.view.devicePixelRatio = 1;
          tester.platformDispatcher.textScaleFactorTestValue = layout.$2;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          final store = SteadyStore(
            now: () => DateTime(2026, 10, 10),
            activityRepository: FakeActivityRepository(),
          );
          final auth = FakeAuth();
          addTearDown(store.dispose);
          addTearDown(auth.dispose);
          await tester.pumpWidget(
            SteadyApp(store: store, auth: auth, initialLocale: Locale(code)),
          );
          await tester.pumpAndSettle();
          Future<void> inspectScroll() async {
            final finder = find.byType(Scrollable).hitTestable().first;
            final scroll = tester.state<ScrollableState>(finder).position;
            for (
              double offset = 0;
              offset < scroll.maxScrollExtent;
              offset += 300
            ) {
              scroll.jumpTo(offset);
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
            }
            scroll.jumpTo(scroll.maxScrollExtent);
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            scroll.jumpTo(0);
            await tester.pumpAndSettle();
          }

          for (var tab = 0; tab < 5; tab++) {
            await tester.tap(find.byType(NavigationDestination).at(tab));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            await inspectScroll();
          }
          await openSignIn(tester);
          expect(find.byType(SignInScreen), findsOneWidget);
          await inspectScroll();
          await tapVisible(tester, find.byKey(const ValueKey('auth-email')));
          await tester.enterText(
            find.byKey(const ValueKey('auth-email')),
            'ban@example.com',
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();
          final context = tester.element(find.byType(NavigationBar));
          Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (_) => ScreeningScreen(
                initial: null,
                onCompleted: (_) {},
                onDeclined: () {},
              ),
            ),
          );
          await tester.pumpAndSettle();
          await inspectScroll();
          await tester.pumpWidget(const SizedBox());
        },
      );
    }
  }
}
