import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steady/reminders/native_reminders.dart';
import 'package:steady/reminders/reminder_controller.dart';
import 'package:timezone/timezone.dart' as tz;

class FakeNotifications implements FlutterLocalNotificationsPlugin {
  final active = <int, tz.TZDateTime>{};
  final cancelled = <int>[];
  final modes = <AndroidScheduleMode>[];
  final repeats = <DateTimeComponents?>[];
  int? failId;
  Completer<void>? gate;
  final entered = Completer<void>();
  @override
  Future<void> cancel(int id, {String? tag}) async {
    active.remove(id);
    cancelled.add(id);
  }

  @override
  Future<void> zonedSchedule(
    int id,
    String? title,
    String? body,
    tz.TZDateTime scheduledDate,
    NotificationDetails notificationDetails, {
    required AndroidScheduleMode androidScheduleMode,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    if (id == failId) throw StateError('native scheduling failed');
    active[id] = scheduledDate;
    modes.add(androidScheduleMode);
    repeats.add(matchDateTimeComponents);
    if (gate != null) {
      final wait = gate!;
      gate = null;
      if (!entered.isCompleted) entered.complete();
      await wait.future;
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test(
    'two stable IDs, daily IANA times, inexact mode; edits replace old times',
    () async {
      final plugin = FakeNotifications();
      final device = NativeReminderDevice.testing(plugin);
      await device.schedule(const ReminderSettings(enabled: true), () => true);
      expect(plugin.active.keys, [71001, 71002]);
      expect(plugin.active[71001]!.hour, 7);
      expect(plugin.active[71002]!.hour, 18);
      expect(plugin.active[71002]!.minute, 30);
      for (final date in plugin.active.values) {
        expect(date.location.name, 'Asia/Ho_Chi_Minh');
        expect(date.isAfter(tz.TZDateTime.now(date.location)), true);
      }
      expect(
        plugin.modes,
        everyElement(AndroidScheduleMode.inexactAllowWhileIdle),
      );
      expect(plugin.repeats, everyElement(DateTimeComponents.time));
      await device.schedule(
        const ReminderSettings(
          enabled: true,
          morning: '09:12',
          timezone: 'Europe/London',
        ),
        () => true,
      );
      expect(plugin.active.length, 2);
      expect(plugin.active[71001]!.hour, 9);
      expect(plugin.active[71001]!.minute, 12);
      expect(plugin.active[71001]!.location.name, 'Europe/London');
      await device.stop();
      expect(plugin.active, isEmpty);
      expect(plugin.cancelled, containsAll(NativeReminderDevice.ids));
    },
  );
  test('partial failure cancels both schedules', () async {
    final plugin = FakeNotifications()..failId = 71002;
    final device = NativeReminderDevice.testing(plugin);
    await expectLater(
      device.schedule(const ReminderSettings(enabled: true), () => true),
      throwsStateError,
    );
    expect(plugin.active, isEmpty);
  });
  test(
    'logout during native await is cleaned before another owner schedules',
    () async {
      final plugin = FakeNotifications();
      final device = NativeReminderDevice.testing(plugin);
      var oldOwner = true;
      final blocker = Completer<void>();
      plugin.gate = blocker;
      final old = device.schedule(
        const ReminderSettings(enabled: true),
        () => oldOwner,
      );
      await plugin.entered.future;
      oldOwner = false;
      final logout = device.stop();
      final next = device.schedule(
        const ReminderSettings(enabled: true, morning: '11:20'),
        () => true,
      );
      blocker.complete();
      await Future.wait([old, logout, next]);
      expect(plugin.active.length, 2);
      expect(plugin.active[71001]!.hour, 11);
      expect(plugin.active[71001]!.minute, 20);
    },
  );
  test('an already stale response never mutates native schedules', () async {
    final plugin = FakeNotifications();
    final device = NativeReminderDevice.testing(plugin);
    await device.schedule(const ReminderSettings(enabled: true), () => false);
    expect(plugin.active, isEmpty);
    expect(plugin.cancelled, isEmpty);
  });
}
