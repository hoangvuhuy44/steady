// flutter test tool/screening_visual_review_test.dart --no-pub
//   --dart-define=PREVIEW_FONT=C:/Windows/Fonts/arial.ttf
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steady/app/steady_app.dart';
import 'package:steady/auth/auth_controller.dart';
import 'package:steady/nutrition/nutrition_strategy.dart';

import '../test/auth_screening_widget_test.dart'
    show FakeAuth, enterScreeningValue;
import '../test/widget_test.dart' show tapVisible;

void main() {
  testWidgets('capture auth and screening in both languages', (tester) async {
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    const fontPath = String.fromEnvironment('PREVIEW_FONT');
    if (fontPath.isNotEmpty) {
      await (FontLoader('Roboto')..addFont(
            Future.value(
              ByteData.sublistView(File(fontPath).readAsBytesSync()),
            ),
          ))
          .load();
    }
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final code in ['vi', 'en']) {
      final auth = FakeAuth()..providers = SocialAuthProvider.values.toSet();
      final boundary = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: SteadyApp(
            key: UniqueKey(),
            auth: auth,
            initialLocale: Locale(code),
          ),
        ),
      );
      Future<void> capture(String suffix) async {
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          final render =
              boundary.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
          final image = await render.toImage();
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File('docs/screenshots/screening-$code-$suffix.png');
          await file.parent.create(recursive: true);
          await file.writeAsBytes(data!.buffer.asUint8List());
          image.dispose();
        });
      }

      await capture('sign-in');
      auth.login('preview');
      await tester.pumpAndSettle();
      await enterScreeningValue(tester, 'age', '35');
      await enterScreeningValue(tester, 'height', '170');
      await enterScreeningValue(tester, 'weight', '75');
      await enterScreeningValue(tester, 'bodyFat', '20');
      await tapVisible(
        tester,
        find.byType(DropdownButtonFormField<BiologicalSex>),
      );
      await tester.tap(find.text(code == 'vi' ? 'Nam' : 'Male').last);
      await tester.pumpAndSettle();
      await tapVisible(tester, find.byKey(const ValueKey('screening-next')));
      await capture('conditions');
      await tapVisible(
        tester,
        find.byKey(const ValueKey('condition-type2Diabetes')),
      );
      await tapVisible(
        tester,
        find.byKey(const ValueKey('condition-hypertension')),
      );
      await tapVisible(
        tester,
        find.byKey(const ValueKey('screening-treatment-known')),
      );
      await tapVisible(tester, find.byKey(const ValueKey('screening-next')));
      await tapVisible(
        tester,
        find.byKey(const ValueKey('screening-allergies-known')),
      );
      await capture('preferences');
      await tapVisible(tester, find.byKey(const ValueKey('screening-next')));
      await capture('training');
      await tapVisible(tester, find.byKey(const ValueKey('screening-next')));
      await capture('result');
      await tapVisible(tester, find.byKey(const ValueKey('screening-consent')));
      await tapVisible(tester, find.byKey(const ValueKey('screening-next')));
      await capture('menu');
      await tapVisible(tester, find.byKey(const ValueKey('meal-day-0')));
      await capture('portions');
      await tester.pumpWidget(const SizedBox());
      auth.dispose();
    }
  });
}
