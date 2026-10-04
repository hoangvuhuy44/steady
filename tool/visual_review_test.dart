// Manual UI capture: flutter test tool/visual_review_test.dart --no-pub
// Optionally use --dart-define=PREVIEW_FONT=C:/Windows/Fonts/arial.ttf
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steady/app/steady_app.dart';
import 'package:steady/nutrition/meal_planner.dart';
import 'package:steady/state/steady_store.dart';

void main() {
  testWidgets('capture Meals on phone and desktop for visual review', (
    tester,
  ) async {
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    const path = String.fromEnvironment('PREVIEW_FONT');
    if (path.isNotEmpty) {
      final loader = FontLoader('Roboto')
        ..addFont(
          Future.value(ByteData.sublistView(File(path).readAsBytesSync())),
        );
      await loader.load();
    }
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final boundary = GlobalKey();
    Future<void> capture(String name) async {
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final render =
            boundary.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final image = await render.toImage();
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        final out = File('docs/screenshots/$name.png');
        await out.parent.create(recursive: true);
        await out.writeAsBytes(data!.buffer.asUint8List());
        image.dispose();
      });
    }

    for (final code in ['en', 'vi']) {
      for (final planned in [false, true]) {
        final store = SteadyStore();
        if (planned) {
          store.setNutritionProfile(
            const NutritionProfile(
              age: 32,
              height: 170,
              weight: 65,
              goal: 'Ăn uống cân bằng',
              activity: 'Ít vận động',
              cholesterol: 'Chưa biết',
              diet: 'Ăn đa dạng',
              budget: 120000,
              minutes: 30,
              exclusions: {},
            ),
          );
        }
        tester.view.physicalSize = const Size(390, 844);
        await tester.pumpWidget(
          RepaintBoundary(
            key: boundary,
            child: SteadyApp(
              key: UniqueKey(),
              initialLocale: Locale(code),
              store: store,
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byType(NavigationDestination).at(2));
        await capture('meals-$code-${planned ? 'plan' : 'setup'}');
        if (planned) {
          await tester.drag(
            find.byType(ListView).hitTestable().first,
            const Offset(0, -540),
          );
          await capture('meals-$code-recipes');
          tester.view.physicalSize = const Size(1280, 900);
          await capture('meals-$code-desktop');
        }
        await tester.pumpWidget(const SizedBox.shrink());
        store.dispose();
      }
    }
    expect(tester.takeException(), isNull);
  });
}
