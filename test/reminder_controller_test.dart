import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steady/reminders/reminder_controller.dart';
import 'package:steady/reminders/reminder_screen.dart';

class FakeApi implements ReminderApi {
  ReminderSettings settings = const ReminderSettings();
  int registrations = 0, removals = 0, tests = 0;
  bool? demo;
  @override
  Future<ReminderSettings> load() async => settings;
  @override
  Future<void> save(ReminderSettings value) async {
    settings = value;
  }

  @override
  Future<void> register(String token) async {
    registrations++;
  }

  @override
  Future<void> unregister() async {
    removals++;
  }

  @override
  Future<void> test({required bool demo}) async {
    this.demo = demo;
    tests++;
  }
}

class FakeDevice implements ReminderDevice {
  @override
  bool supported = true;
  ReminderPermission status = ReminderPermission.unknown;
  int prompts = 0, tokens = 0, stops = 0;
  @override
  Future<ReminderPermission> permission({bool request = false}) async {
    if (request) {
      prompts++;
      status = ReminderPermission.granted;
    }
    return status;
  }

  @override
  Future<String> token() async {
    tokens++;
    return 'test-token';
  }

  @override
  Future<void> stop() async {
    stops++;
  }
}

void main() {
  late FakeApi api;
  late FakeDevice device;
  late ReminderController controller;
  setUp(() {
    api = FakeApi();
    device = FakeDevice();
    controller = ReminderController(api: api, device: device);
  });
  tearDown(() => controller.dispose());

  test('reading settings never prompts or obtains a push token', () async {
    await controller.refresh();
    expect(device.prompts, 0);
    expect(device.tokens, 0);
    expect(controller.settings.morning, '07:00');
    expect(controller.settings.evening, '18:30');
    expect(controller.settings.timezone, 'Asia/Ho_Chi_Minh');
  });
  test(
    'equal times rejected before permission prompt or persistence',
    () async {
      await controller.enable(
        const ReminderSettings(morning: '07:00', evening: '07:00'),
      );
      expect(controller.error, 'invalid');
      expect(device.prompts, 0);
      expect(api.settings.enabled, false);
    },
  );
  test('enable, update without prompting, demo and disable', () async {
    await controller.enable(const ReminderSettings());
    expect(device.prompts, 1);
    expect(api.registrations, 1);
    expect(controller.registered, true);
    expect(api.settings.enabled, true);
    await controller.save(
      const ReminderSettings(morning: '08:00', timezone: 'America/New_York'),
    );
    expect(device.prompts, 1);
    expect(api.settings.morning, '08:00');
    expect(await controller.test(demo: true), true);
    expect(api.demo, true);
    await controller.disable();
    expect(api.settings.enabled, false);
    expect(device.stops, 1);
    expect(await controller.test(), false);
    expect(api.tests, 1);
  });
  test('permission revoked unregisters current device on refresh', () async {
    api.settings = const ReminderSettings(enabled: true);
    device.status = ReminderPermission.denied;
    await controller.refresh();
    expect(api.removals, 1);
    expect(controller.registered, false);
    expect(device.prompts, 0);
    expect(device.tokens, 0);
  });
  test('unsupported platforms never request permission', () async {
    device.supported = false;
    await controller.enable(const ReminderSettings());
    expect(controller.permission, ReminderPermission.unsupported);
    expect(device.prompts, 0);
    expect(api.registrations, 0);
  });
  testWidgets('opening reminders does not prompt; explicit enable does', (
    tester,
  ) async {
    await controller.refresh();
    await tester.pumpWidget(
      MaterialApp(home: ReminderScreen(controller: controller)),
    );
    expect(
      find.text('Notification permission not granted yet.'),
      findsOneWidget,
    );
    expect(device.prompts, 0);
    await tester.ensureVisible(find.text('Enable workout reminders'));
    await tester.tap(find.text('Enable workout reminders'));
    await tester.pumpAndSettle();
    expect(device.prompts, 1);
    await tester.drag(find.byType(ListView), const Offset(0, 600));
    await tester.pumpAndSettle();
    expect(find.text('Enabled on this device.'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
