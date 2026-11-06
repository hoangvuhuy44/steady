import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as data;
import 'package:timezone/timezone.dart' as tz;

import 'reminder_controller.dart';

class NativeReminderDevice implements ReminderDevice {
  NativeReminderDevice._(this.plugin);
  @visibleForTesting
  NativeReminderDevice.testing(this.plugin);
  final FlutterLocalNotificationsPlugin? plugin;
  Future<void> _tail = Future.value();
  void Function(String?)? onTap;
  String? initialPayload;
  static const ids = [71001, 71002, 71003];
  static const details = NotificationDetails(
    android: AndroidNotificationDetails(
      'workout_local_v1',
      'Workout reminders',
      channelDescription: 'Daily workout reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: 'ic_stat_workout',
    ),
    iOS: DarwinNotificationDetails(),
  );
  static Future<NativeReminderDevice> initialize() async {
    data.initializeTimeZones();
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return NativeReminderDevice._(null);
    }
    final device = NativeReminderDevice._(FlutterLocalNotificationsPlugin());
    await device.plugin!.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('ic_stat_workout'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) =>
          device.onTap?.call(response.payload),
    );
    await device.plugin!
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            'workout_local_v1',
            'Workout reminders',
            description: 'Daily workout reminders',
            importance: Importance.high,
          ),
        );
    final launch = await device.plugin!.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp == true) {
      device.initialPayload = launch!.notificationResponse?.payload;
    }
    return device;
  }

  @override
  bool get supported => plugin != null;
  Future<void> _serialized(Future<void> Function() action) {
    final result = _tail.then((_) => action());
    _tail = result.catchError((Object _) {});
    return result;
  }

  @override
  Future<ReminderPermission> permission({bool request = false}) async {
    if (!supported) return ReminderPermission.unsupported;
    final android = plugin!
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      final granted = request
          ? await android.requestNotificationsPermission()
          : await android.areNotificationsEnabled();
      if (granted != true) return ReminderPermission.denied;
      final channels = await android.getNotificationChannels();
      if (channels?.any(
            (channel) =>
                channel.id == 'workout_local_v1' &&
                channel.importance == Importance.none,
          ) ==
          true) {
        return ReminderPermission.denied;
      }
      return ReminderPermission.granted;
    }
    final ios = plugin!
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()!;
    if (request) {
      return await ios.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              ) ==
              true
          ? ReminderPermission.granted
          : ReminderPermission.denied;
    }
    final status = await ios.checkPermissions();
    return status?.isEnabled == true
        ? ReminderPermission.granted
        : ReminderPermission.unknown;
  }

  Future<void> _cancel() async {
    if (!supported) return;
    for (final id in ids) {
      await plugin!.cancel(id);
    }
  }

  @override
  Future<void> stop() => _serialized(_cancel);
  @override
  Future<void> schedule(ReminderSettings settings, bool Function() current) =>
      _serialized(() async {
        if (!current()) return;
        if (!settings.valid) throw ArgumentError('Invalid reminder settings');
        try {
          await _cancel();
          final location = tz.getLocation(settings.timezone);
          final now = tz.TZDateTime.now(location);
          final times = [settings.morning, settings.evening];
          for (var i = 0; i < times.length; i++) {
            if (!current()) {
              await _cancel();
              return;
            }
            final parts = times[i].split(':').map(int.parse).toList();
            var next = tz.TZDateTime(
              location,
              now.year,
              now.month,
              now.day,
              parts[0],
              parts[1],
            );
            if (!next.isAfter(now)) {
              next = tz.TZDateTime(
                location,
                now.year,
                now.month,
                now.day + 1,
                parts[0],
                parts[1],
              );
            }
            await plugin!.zonedSchedule(
              ids[i],
              'Steady',
              i == 0
                  ? 'Đến giờ vận động buổi sáng!'
                  : 'Dành chút thời gian tập luyện nhé!',
              next,
              details,
              androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
              matchDateTimeComponents: DateTimeComponents.time,
              payload: 'check-in',
            );
          }
          if (!current()) await _cancel();
        } catch (_) {
          await _cancel();
          rethrow;
        }
      });
  @override
  Future<void> test(bool Function() current) => _serialized(() async {
    if (!current()) return;
    await plugin!.show(
      ids[2],
      'Steady',
      'Thông báo thử: đến giờ tập luyện!',
      details,
      payload: 'check-in',
    );
    if (!current()) await _cancel();
  });
}

class PreferencesReminderCache implements ReminderCache {
  PreferencesReminderCache(String userId) : key = 'local-reminders-v1-$userId';
  final String key;
  @override
  Future<ReminderCacheEntry?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return null;
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return ReminderCacheEntry(
      ReminderSettings.fromJson(json),
      json['pending'] as bool,
    );
  }

  @override
  Future<void> save(ReminderSettings settings, {required bool pending}) async {
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString(
      key,
      jsonEncode({...settings.toJson(), 'pending': pending}),
    )) {
      throw StateError('Could not persist reminders');
    }
  }
}

class SupabaseReminderApi implements ReminderApi {
  SupabaseReminderApi(this.client, this.userId);
  final SupabaseClient client;
  final String userId;
  void _checkOwner() {
    if (client.auth.currentUser?.id != userId) {
      throw StateError('Session changed');
    }
  }

  @override
  Future<ReminderSettings> load() async {
    _checkOwner();
    final row = await client.rpc('local_reminder_settings');
    _checkOwner();
    return row == null
        ? const ReminderSettings()
        : ReminderSettings.fromJson(Map<String, dynamic>.from(row as Map));
  }

  @override
  Future<void> save(ReminderSettings settings) async {
    _checkOwner();
    await client.from('workout_reminders').upsert({
      'user_id': userId,
      ...settings.toJson(),
    });
    _checkOwner();
  }
}
