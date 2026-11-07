import 'package:flutter/services.dart';
import 'package:timezone/timezone.dart' as tz;

import 'iana_data.dart' as data;

/// Reads the OS zone ID, never an abbreviation or a guessed UTC offset.
Future<String> readDeviceTimezone() async {
  final id = await const MethodChannel('steady/device_timezone')
      .invokeMethod<String>('getTimezone')
      .timeout(const Duration(seconds: 5));
  data.initializeTimeZones();
  if (id == null || !tz.timeZoneDatabase.locations.containsKey(id)) {
    throw StateError('Device timezone is not available in the IANA database');
  }
  return id;
}
