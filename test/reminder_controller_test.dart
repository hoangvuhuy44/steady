import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steady/reminders/reminder_controller.dart';
import 'package:steady/reminders/reminder_screen.dart';
import 'package:steady/reminders/native_reminders.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeApi implements ReminderApi {
  ReminderSettings settings = const ReminderSettings();
  bool offline = false;
  int saves = 0, loads = 0;
  Completer<ReminderSettings>? delayed;
  @override
  Future<ReminderSettings> load() async {
    loads++;
    if (offline) throw StateError('offline');
    return delayed == null ? settings : delayed!.future;
  }

  @override
  Future<void> save(ReminderSettings value) async {
    if (offline) throw StateError('offline');
    saves++;
    settings = value;
  }
}

class FakeDevice implements ReminderDevice {
  @override
  bool supported = true;
  ReminderPermission status = ReminderPermission.granted;
  int prompts = 0, stops = 0, tests = 0;
  bool fail = false;
  final schedules = <ReminderSettings>[];
  @override
  Future<ReminderPermission> permission({bool request = false}) async {
    if (request) prompts++;
    return status;
  }

  @override
  Future<void> schedule(ReminderSettings value, bool Function() current) async {
    if (fail) throw StateError('schedule failed');
    if (current()) schedules.add(value);
  }

  @override
  Future<void> test(bool Function() current) async {
    if (current()) tests++;
  }

  @override
  Future<void> stop() async {
    stops++;
  }
}

class BrokenCache extends MemoryReminderCache {
  @override
  Future<void> save(ReminderSettings settings, {required bool pending}) async =>
      throw StateError('disk full');
}

void main() {
  late FakeApi api;
  late FakeDevice device;
  late MemoryReminderCache cache;
  late ReminderController controller;
  setUp(() {
    api = FakeApi();
    device = FakeDevice();
    cache = MemoryReminderCache();
    controller = ReminderController(api: api, device: device, cache: cache);
  });
  tearDown(() => controller.dispose());
  test('startup has defaults and never prompts', () async {
    await controller.refresh();
    expect(device.prompts, 0);
    expect(controller.settings.toJson(), const ReminderSettings().toJson());
  });
  test(
    'invalid hours, identical times and unknown timezone rejected',
    () async {
      for (final draft in [
        const ReminderSettings(morning: '24:00'),
        const ReminderSettings(morning: '7:00'),
        const ReminderSettings(morning: '18:30'),
        const ReminderSettings(timezone: 'Invalid/Nowhere'),
      ]) {
        await controller.enable(draft);
        expect(controller.error, 'invalid');
      }
      expect(device.prompts, 0);
      expect(api.saves, 0);
    },
  );
  test('enable, change time/timezone and disable update device', () async {
    await controller.enable(const ReminderSettings());
    expect(controller.registered, true);
    await controller.save(
      const ReminderSettings(morning: '08:10', timezone: 'America/New_York'),
    );
    expect(device.schedules.last.morning, '08:10');
    expect(device.schedules.last.timezone, 'America/New_York');
    expect(device.prompts, 1);
    await controller.disable();
    expect(controller.settings.enabled, false);
    expect(controller.registered, false);
    expect(api.settings.enabled, false);
    expect(device.stops, greaterThan(0));
  });
  test('denied permission never reports success or enables remote', () async {
    device.status = ReminderPermission.denied;
    await controller.enable(const ReminderSettings());
    expect(controller.error, 'permission');
    expect(controller.registered, false);
    expect(api.saves, 0);
    expect(device.schedules, isEmpty);
    expect(await controller.test(), false);
  });
  test('schedule failure does not report enabled on device', () async {
    device.fail = true;
    await controller.enable(const ReminderSettings());
    expect(controller.error, 'schedule');
    expect(controller.registered, false);
    expect(api.saves, 0);
  });
  test('offline edits schedule locally, persist pending and retry', () async {
    api.offline = true;
    await controller.enable(const ReminderSettings(morning: '09:00'));
    expect(controller.registered, true);
    expect(controller.error, 'sync');
    expect(cache.entry!.pending, true);
    api.offline = false;
    await controller.refresh();
    expect(api.settings.morning, '09:00');
    expect(controller.pendingSync, false);
    expect(cache.entry!.pending, false);
  });
  test('offline startup restores account cache before network', () async {
    await cache.save(const ReminderSettings(enabled: true), pending: false);
    api.offline = true;
    await controller.refresh();
    expect(controller.registered, true);
    expect(device.prompts, 0);
    expect(controller.settings.enabled, true);
    expect(controller.error, 'sync');
  });
  test('disable offline cancels and uploads later', () async {
    await controller.enable(const ReminderSettings());
    api.offline = true;
    await controller.disable();
    expect(controller.registered, false);
    expect(cache.entry!.settings.enabled, false);
    expect(controller.pendingSync, true);
    api.offline = false;
    await controller.refresh();
    expect(api.settings.enabled, false);
  });
  test('local disk failure has specific error and no remote write', () async {
    final c = ReminderController(
      api: api,
      device: device,
      cache: BrokenCache(),
    );
    await c.enable(const ReminderSettings());
    expect(c.error, 'cache');
    expect(c.registered, false);
    expect(api.saves, 0);
    c.dispose();
  });
  test(
    'test notification is local, works while disabled and offline',
    () async {
      api.offline = true;
      expect(await controller.test(), true);
      expect(device.tests, 1);
      expect(api.loads, 0);
      expect(api.saves, 0);
      expect(device.prompts, 1);
    },
  );
  test('late sync after logout never reinstalls schedules', () async {
    api.delayed = Completer();
    final refreshing = controller.refresh();
    await Future<void>.delayed(Duration.zero);
    await controller.detach();
    api.delayed!.complete(const ReminderSettings(enabled: true));
    await refreshing;
    expect(device.schedules, isEmpty);
    expect(controller.registered, false);
    expect(device.stops, greaterThan(0));
  });
  test('owner change while load pending discards old reply', () async {
    var owner = true;
    final c = ReminderController(
      api: api,
      device: device,
      isOwner: () => owner,
    );
    api.delayed = Completer();
    final refreshing = c.refresh();
    await Future<void>.delayed(Duration.zero);
    owner = false;
    api.delayed!.complete(const ReminderSettings(enabled: true));
    await refreshing;
    expect(device.schedules, isEmpty);
    c.dispose();
  });
  test(
    'remote edits and disable take effect at next synchronization',
    () async {
      await controller.enable(const ReminderSettings());
      api.settings = const ReminderSettings(enabled: true, evening: '20:00');
      await controller.refresh();
      expect(device.schedules.last.evening, '20:00');
      api.settings = const ReminderSettings();
      await controller.refresh();
      expect(controller.registered, false);
      expect(controller.settings.enabled, false);
    },
  );
  test('revoked permission still synchronizes remote disable', () async {
    await controller.enable(const ReminderSettings());
    device.status = ReminderPermission.denied;
    api.settings = const ReminderSettings();
    await controller.refresh();
    expect(controller.settings.enabled, false);
    expect(controller.registered, false);
  });
  test('preferences cache is isolated per account', () async {
    SharedPreferences.setMockInitialValues({});
    final a = PreferencesReminderCache('a'), b = PreferencesReminderCache('b');
    await a.save(
      const ReminderSettings(enabled: true, morning: '08:00'),
      pending: true,
    );
    expect(await b.load(), isNull);
    expect((await a.load())!.settings.morning, '08:00');
    expect((await a.load())!.pending, true);
  });
  testWidgets('local test remains available without enabled reminders', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: ReminderScreen(controller: controller)),
    );
    await tester.enterText(find.byType(TextField).first, '08:55');
    await tester.ensureVisible(find.text('Send test notification'));
    await tester.tap(find.text('Send test notification'));
    await tester.pumpAndSettle();
    expect(device.tests, 1);
    expect(api.saves, 0);
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      '08:55',
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
