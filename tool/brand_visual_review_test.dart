// flutter test tool/brand_visual_review_test.dart --no-pub
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steady/app/steady_app.dart';
import 'package:steady/auth/auth_controller.dart';
import 'package:steady/screens/screening_screen.dart';
import 'package:steady/state/steady_store.dart';

import '../test/helpers/brand_fonts.dart';
import '../test/helpers/fake_activity_repository.dart';
import '../test/auth_screening_widget_test.dart' show FakeAuth, openSignIn;
import '../test/health_screening_test.dart' show screening;

void main() {
  testWidgets('capture shipped fonts and branded screens in VI/EN', (
    tester,
  ) async {
    await loadBrandFonts();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final code in ['vi', 'en']) {
      final store = SteadyStore(
        now: () => DateTime(2026, 10, 10),
        activityRepository: FakeActivityRepository(),
      );
      final auth = FakeAuth()..providers = SocialAuthProvider.values.toSet();
      final boundary = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: SteadyApp(
            key: UniqueKey(),
            store: store,
            auth: auth,
            initialLocale: Locale(code),
          ),
        ),
      );
      Future<void> capture(String screen) async {
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.runAsync(() async {
          final render =
              boundary.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
          final image = await render.toImage();
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          final out = File('docs/screenshots/brand/$code-$screen.png');
          await out.parent.create(recursive: true);
          await out.writeAsBytes(data!.buffer.asUint8List());
          image.dispose();
        });
      }

      await tester.pumpAndSettle();
      // Asset decoding is asynchronous in widget tests. Wait for the exact
      // bundled artwork before capturing the first frame.
      final context = tester.element(find.byType(NavigationBar));
      await tester.runAsync(() async {
        final assets = Directory('assets/brand')
            .listSync(recursive: true)
            .whereType<File>()
            .where((file) => file.path.endsWith('.png'));
        await Future.wait(
          assets.map(
            (file) => precacheImage(
              AssetImage(file.path.replaceAll('\\', '/')),
              context,
            ),
          ),
        );
      });
      await tester.pumpAndSettle();
      for (var index = 0; index < 5; index++) {
        await tester.tap(find.byType(NavigationDestination).at(index));
        await capture(
          ['home', 'check-in', 'meals', 'rewards', 'profile'][index],
        );
      }
      await openSignIn(tester);
      await capture('sign-in');
      await tester.tap(find.byKey(const ValueKey('auth-cancel')));
      await tester.pumpAndSettle();
      Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => ScreeningScreen(
            initial: screening(),
            onCompleted: (_) {},
            onDeclined: () {},
          ),
        ),
      );
      await capture('screening');
      await tester.pumpWidget(const SizedBox());
      store.dispose();
      auth.dispose();
    }
  });
}
