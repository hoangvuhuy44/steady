import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:steady/reminders/native_reminders.dart';
import 'package:steady/reminders/reminder_controller.dart';
import 'package:steady/time/iana_data.dart' as data;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUp(data.initializeTimeZones);

  test('2026f keeps Cuba on UTC-04 through the cancelled 2026 fallback', () {
    expect(data.ianaVersion, '2026f');
    final havana = tz.getLocation('America/Havana');
    for (final date in [DateTime.utc(2026, 11, 6), DateTime.utc(2027, 1, 15)]) {
      expect(
        tz.TZDateTime.from(date, havana).timeZoneOffset,
        const Duration(hours: -4),
      );
    }
  });

  test(
    'initialization and settings validation both retain updated data',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      await NativeReminderDevice.initialize();
      expect(const ReminderSettings(timezone: 'America/Havana').valid, isTrue);
      expect(
        tz.TZDateTime(
          tz.getLocation('America/Havana'),
          2026,
          11,
          6,
        ).timeZoneOffset,
        const Duration(hours: -4),
      );
      expect(const ReminderSettings(timezone: 'Unknown/Zone').valid, isFalse);
    },
  );

  test('legacy IANA aliases stay usable without rewriting saved IDs', () {
    for (final pair in [
      ['Asia/Saigon', 'Asia/Ho_Chi_Minh'],
      ['US/Eastern', 'America/New_York'],
      ['Cuba', 'America/Havana'],
    ]) {
      expect(ReminderSettings(timezone: pair.first).valid, isTrue);
      final instant = DateTime.utc(2026, 11, 6);
      expect(
        tz.TZDateTime.from(instant, tz.getLocation(pair.first)).timeZoneOffset,
        tz.TZDateTime.from(instant, tz.getLocation(pair.last)).timeZoneOffset,
      );
    }
  });

  test('Monday boundaries preserve DST week lengths', () {
    final ny = tz.getLocation('America/New_York');
    expect(
      tz.TZDateTime(ny, 2026, 3, 9).difference(tz.TZDateTime(ny, 2026, 3, 2)),
      const Duration(hours: 167),
    );
    expect(
      tz.TZDateTime(
        ny,
        2026,
        11,
        2,
      ).difference(tz.TZDateTime(ny, 2026, 10, 26)),
      const Duration(hours: 169),
    );
  });
}
