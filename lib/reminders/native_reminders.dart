import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'reminder_controller.dart';

class NativeReminderDevice implements ReminderDevice {
  NativeReminderDevice(this.messaging);
  final FirebaseMessaging? messaging;

  static Future<NativeReminderDevice> initialize() async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return NativeReminderDevice(null);
    }
    const appId = String.fromEnvironment('FIREBASE_APP_ID');
    const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
    const sender = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
    const project = String.fromEnvironment('FIREBASE_PROJECT_ID');
    if ([appId, apiKey, sender, project].any((s) => s.isEmpty)) {
      return NativeReminderDevice(null);
    }
    try {
      const options = FirebaseOptions(
        apiKey: apiKey,
        appId: appId,
        messagingSenderId: sender,
        projectId: project,
        iosBundleId: String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID'),
      );
      // Android requires native resources for process starts in background too.
      final app = defaultTargetPlatform == TargetPlatform.android
          ? await Firebase.initializeApp()
          : await Firebase.initializeApp(options: options);
      if (app.options.appId != appId ||
          app.options.projectId != project ||
          app.options.messagingSenderId != sender ||
          app.options.apiKey != apiKey) {
        throw StateError(
          'Native Firebase config differs from Dart configuration',
        );
      }
      return NativeReminderDevice(FirebaseMessaging.instance);
    } catch (_) {
      debugPrint('FCM initialization failed; reminders unavailable.');
      return NativeReminderDevice(null);
    }
  }

  @override
  bool get supported => messaging != null;

  @override
  Future<ReminderPermission> permission({bool request = false}) async {
    if (messaging == null) return ReminderPermission.unsupported;
    final settings = request
        ? await messaging!.requestPermission(
            alert: true,
            badge: true,
            sound: true,
          )
        : await messaging!.getNotificationSettings();
    return switch (settings.authorizationStatus) {
      AuthorizationStatus.authorized ||
      AuthorizationStatus.provisional => ReminderPermission.granted,
      AuthorizationStatus.denied ||
      AuthorizationStatus.deniedPermanently => ReminderPermission.denied,
      AuthorizationStatus.notDetermined => ReminderPermission.unknown,
    };
  }

  @override
  Future<String> token() async {
    // Called only after checking/requesting permission, never at app startup.
    if (await permission() != ReminderPermission.granted) {
      throw StateError('Permission required');
    }
    await messaging!.setAutoInitEnabled(true);
    // HTTP v1 requires registration tokens; retained API in pinned FCM SDK 17.
    // ignore: deprecated_member_use
    final token = await messaging!.getToken();
    if (token == null) {
      throw StateError('APNs/FCM token not ready; retry after a moment');
    }
    return token;
  }

  @override
  Future<void> stop() async {
    if (messaging == null) return;
    await messaging!.setAutoInitEnabled(false);
    // ignore: deprecated_member_use
    await messaging!.deleteToken();
  }
}

class SupabaseReminderApi implements ReminderApi {
  SupabaseReminderApi(this.client, this.userId);
  final SupabaseClient client;
  final String userId;
  String? _id;
  void _checkOwner() {
    if (client.auth.currentUser?.id != userId) {
      throw StateError('Session changed');
    }
  }

  Future<String> deviceId() async {
    if (_id != null) return _id!;
    final preferences = await SharedPreferences.getInstance();
    final key = 'reminder-device-$userId';
    final id = preferences.getString(key) ?? const Uuid().v4();
    await preferences.setString(key, id);
    return _id = id;
  }

  @override
  Future<ReminderSettings> load() async {
    _checkOwner();
    return ReminderSettings.fromJson(
      Map<String, dynamic>.from(await client.rpc('reminder_settings') as Map),
    );
  }

  @override
  Future<void> save(ReminderSettings settings) async {
    _checkOwner();
    await client.rpc(
      'reminder_save',
      params: {
        'p_enabled': settings.enabled,
        'p_morning': settings.morning,
        'p_evening': settings.evening,
        'p_timezone': settings.timezone,
      },
    );
  }

  @override
  Future<void> register(String token) async {
    final id = await deviceId();
    _checkOwner();
    await client.rpc(
      'reminder_device',
      params: {
        'p_id': id,
        'p_token': token,
        'p_platform': defaultTargetPlatform == TargetPlatform.iOS
            ? 'ios'
            : 'android',
        'p_active': true,
      },
    );
  }

  @override
  Future<void> unregister() async {
    final id = await deviceId();
    _checkOwner();
    await client.rpc(
      'reminder_device',
      params: {
        'p_id': id,
        'p_token': '',
        'p_platform': 'android',
        'p_active': false,
      },
    );
  }

  @override
  Future<void> test({required bool demo}) async {
    final id = await deviceId();
    _checkOwner();
    await client.rpc('reminder_test', params: {'p_device': id, 'p_demo': demo});
  }
}
