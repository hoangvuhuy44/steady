import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steady/reminders/reminder_controller.dart';
import 'package:steady/reminders/reminder_screen.dart';
import 'package:steady/reminders/timezone_selector.dart';
import 'package:steady/time/device_timezone.dart';

import 'reminder_controller_test.dart' show FakeApi, FakeDevice;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('steady/device_timezone');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('device reader preserves IANA IDs and rejects unknown zones', () async {
    messenger.setMockMethodCallHandler(channel, (_) async => 'Asia/Kathmandu');
    expect(await readDeviceTimezone(), 'Asia/Kathmandu');
    messenger.setMockMethodCallHandler(channel, (_) async => 'Imaginary/Zone');
    await expectLater(readDeviceTimezone(), throwsStateError);
  });

  testWidgets('search and save a timezone outside GMT+7', (tester) async {
    final api = FakeApi();
    final device = FakeDevice();
    final controller = ReminderController(api: api, device: device);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(home: ReminderScreen(controller: controller)),
    );
    await tester.tap(find.byKey(const ValueKey('reminder-timezone')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('timezone-search')),
      'new york',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('America/New_York'));
    await tester.pumpAndSettle();
    expect(api.saves, 0);
    await tester.ensureVisible(find.text('Enable workout reminders'));
    await tester.tap(find.text('Enable workout reminders'));
    await tester.pumpAndSettle();
    expect(api.settings.timezone, 'America/New_York');
    expect(device.schedules.last.timezone, 'America/New_York');
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('device timezone is a draft; failed reads retain selected zone', (
    tester,
  ) async {
    final value = TextEditingController(text: 'Europe/Berlin');
    addTearDown(value.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TimezoneSelector(controller: value, enabled: true),
        ),
      ),
    );
    messenger.setMockMethodCallHandler(channel, (_) async => 'Asia/Tokyo');
    await tester.tap(find.byKey(const ValueKey('use-device-timezone')));
    await tester.pumpAndSettle();
    expect(value.text, 'Asia/Tokyo');
    messenger.setMockMethodCallHandler(channel, (_) async => 'Unknown/Zone');
    await tester.tap(find.byKey(const ValueKey('use-device-timezone')));
    await tester.pumpAndSettle();
    expect(value.text, 'Asia/Tokyo');
    expect(find.byKey(const ValueKey('timezone-error')), findsOneWidget);
  });

  testWidgets('late device read does not overwrite newer settings', (
    tester,
  ) async {
    final result = Completer<String>();
    messenger.setMockMethodCallHandler(channel, (_) => result.future);
    final value = TextEditingController(text: 'Europe/Berlin');
    addTearDown(value.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TimezoneSelector(controller: value, enabled: true),
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('use-device-timezone')));
    await tester.pump();
    value.text = 'America/Los_Angeles';
    result.complete('Asia/Tokyo');
    await tester.pumpAndSettle();
    expect(value.text, 'America/Los_Angeles');
  });

  testWidgets(
    'picker handles empty searches and cancellation on a small screen',
    (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final value = TextEditingController(text: 'Europe/Berlin');
      addTearDown(value.dispose);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: Scaffold(
            body: SingleChildScrollView(
              child: TimezoneSelector(controller: value, enabled: true),
            ),
          ),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('reminder-timezone')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('timezone-search')),
        'nothing-matches',
      );
      await tester.pumpAndSettle();
      expect(find.text('No timezones found'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(value.text, 'Europe/Berlin');
    },
  );
}
