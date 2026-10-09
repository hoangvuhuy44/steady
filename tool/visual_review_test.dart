// Manual UI capture: flutter test tool/visual_review_test.dart --no-pub
// Optionally use --dart-define=PREVIEW_FONT=C:/Windows/Fonts/arial.ttf
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steady/app/steady_app.dart';
import 'package:steady/l10n/app_localizations.dart';
import 'package:steady/state/steady_store.dart';

import '../test/helpers/fake_activity_repository.dart';
import '../test/widget_test.dart' show tapVisible;

void main() {
  testWidgets('capture MVP recipes on phone and with large text', (
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
      for (final largeText in [false, true]) {
        final store = SteadyStore(activityRepository: FakeActivityRepository());
        tester.platformDispatcher.textScaleFactorTestValue = largeText ? 2 : 1;
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
        final suffix = largeText ? 'large-text' : 'phone';
        await capture('recipes-$code-catalogue-$suffix');
        final l = await AppLocalizations.delegate.load(Locale(code));
        await tapVisible(tester, find.text(l.recipesFilters));
        await tapVisible(
          tester,
          find.byKey(const ValueKey('recipe-avoid-label-soy')),
        );
        await capture('recipes-$code-filters-$suffix');
        await tapVisible(
          tester,
          find.byKey(const ValueKey('recipe-clear-filters')),
        );
        await tapVisible(tester, find.text(l.recipesFilters));
        await tapVisible(
          tester,
          find.byKey(const ValueKey('recipe-card-oats')),
        );
        await capture('recipes-$code-detail-$suffix');
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        store.dispose();
      }
    }
    tester.platformDispatcher.clearTextScaleFactorTestValue();
    expect(tester.takeException(), isNull);
  });
}
