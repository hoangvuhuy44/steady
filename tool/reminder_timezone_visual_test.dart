import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steady/reminders/reminder_controller.dart';
import 'package:steady/reminders/reminder_screen.dart';

import '../test/reminder_controller_test.dart' show FakeApi, FakeDevice;

void main() {
  testWidgets('capture reminder timezone picker', (tester) async {
    await (FontLoader('Roboto')..addFont(
          Future.value(
            ByteData.sublistView(
              File('C:/Windows/Fonts/arial.ttf').readAsBytesSync(),
            ),
          ),
        ))
        .load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final locale in ['en', 'vi']) {
      final controller = ReminderController(
        api: FakeApi(),
        device: FakeDevice(),
      );
      final boundary = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: MaterialApp(
            locale: Locale(locale),
            supportedLocales: const [Locale('en'), Locale('vi')],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            home: ReminderScreen(controller: controller),
          ),
        ),
      );
      await tester.pumpAndSettle();
      Future<void> capture(String name) async {
        await tester.runAsync(() async {
          final image =
              await (boundary.currentContext!.findRenderObject()
                      as RenderRepaintBoundary)
                  .toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File(
            'docs/screenshots/reminder-timezone-$locale-$name.png',
          );
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }

      await capture('screen');
      await tester.tap(find.byKey(const ValueKey('reminder-timezone')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('timezone-search')),
        'America',
      );
      await tester.pumpAndSettle();
      await capture('picker');
      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    }
  });
}
