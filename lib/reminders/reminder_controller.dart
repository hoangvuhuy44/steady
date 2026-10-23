import 'dart:async';

import 'package:flutter/foundation.dart';

enum ReminderPermission { unknown, granted, denied, unsupported }

class ReminderSettings {
  const ReminderSettings({
    this.enabled = false,
    this.morning = '07:00',
    this.evening = '18:30',
    this.timezone = 'Asia/Ho_Chi_Minh',
  });
  final bool enabled;
  final String morning, evening, timezone;

  factory ReminderSettings.fromJson(Map<String, dynamic> json) =>
      ReminderSettings(
        enabled: json['enabled'] as bool,
        morning: (json['morning'] as String).substring(0, 5),
        evening: (json['evening'] as String).substring(0, 5),
        timezone: json['timezone'] as String,
      );

  bool get valid =>
      RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(morning) &&
      RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(evening) &&
      morning != evening &&
      timezone.trim().isNotEmpty;
}

abstract interface class ReminderApi {
  Future<ReminderSettings> load();
  Future<void> save(ReminderSettings settings);
  Future<void> register(String token);
  Future<void> unregister();
  Future<void> test({required bool demo});
}

abstract interface class ReminderDevice {
  bool get supported;
  Future<ReminderPermission> permission({bool request = false});
  Future<String> token();
  Future<void> stop();
}

class ReminderController extends ChangeNotifier {
  ReminderController({required this.api, required this.device});
  final ReminderApi api;
  final ReminderDevice device;
  ReminderSettings settings = const ReminderSettings();
  ReminderPermission permission = ReminderPermission.unknown;
  bool busy = false, registered = false;
  bool _disposed = false;
  String? error;
  int _generation = 0;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  /// Reads permission only. The OS prompt belongs exclusively to enable().
  Future<void> refresh() async {
    final generation = ++_generation;
    if (!device.supported) permission = ReminderPermission.unsupported;
    busy = true;
    registered = false;
    error = null;
    _notify();
    try {
      final loaded = await api.load();
      final status = device.supported
          ? await device.permission()
          : ReminderPermission.unsupported;
      if (generation != _generation || _disposed) return;
      settings = loaded;
      permission = status;
      if (settings.enabled && permission == ReminderPermission.granted) {
        await api.register(await device.token());
        if (generation == _generation) registered = true;
      } else if (permission != ReminderPermission.granted && device.supported) {
        // A permission revoked in system settings must stop this device.
        await api.unregister();
      }
    } catch (_) {
      if (generation == _generation) error = 'load';
    } finally {
      if (generation == _generation) {
        busy = false;
        _notify();
      }
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    if (busy) return;
    busy = true;
    error = null;
    _notify();
    try {
      await action();
    } catch (_) {
      error = 'operation';
    } finally {
      busy = false;
      _notify();
    }
  }

  Future<void> enable(ReminderSettings draft) => _run(() async {
    if (!draft.valid) {
      error = 'invalid';
      return;
    }
    if (!device.supported) {
      permission = ReminderPermission.unsupported;
      return;
    }
    permission = await device.permission(request: true);
    if (permission != ReminderPermission.granted) return;
    // Register first; settings are not enabled if registration fails.
    await api.register(await device.token());
    await api.save(
      ReminderSettings(
        enabled: true,
        morning: draft.morning,
        evening: draft.evening,
        timezone: draft.timezone.trim(),
      ),
    );
    settings = ReminderSettings(
      enabled: true,
      morning: draft.morning,
      evening: draft.evening,
      timezone: draft.timezone.trim(),
    );
    registered = true;
  });

  Future<void> save(ReminderSettings draft) => _run(() async {
    if (!draft.valid) {
      error = 'invalid';
      return;
    }
    final next = ReminderSettings(
      enabled: settings.enabled,
      morning: draft.morning,
      evening: draft.evening,
      timezone: draft.timezone.trim(),
    );
    await api.save(next);
    settings = next;
  });

  Future<void> disable() => _run(() async {
    final next = ReminderSettings(
      morning: settings.morning,
      evening: settings.evening,
      timezone: settings.timezone,
    );
    await api.save(next);
    settings = next;
    registered = false;
    await device.stop();
  });

  Future<bool> test({bool demo = false}) async {
    var queued = false;
    await _run(() async {
      if (!settings.enabled ||
          !registered ||
          permission != ReminderPermission.granted) {
        throw StateError('Enable this device first');
      }
      await api.test(demo: demo);
      queued = true;
    });
    return queued;
  }

  /// Called before sign-out while the owner's JWT is still available.
  Future<void> detach() async {
    if (!device.supported) return;
    if (busy) throw StateError('Wait for reminder operation');
    ++_generation;
    await api.unregister();
    registered = false;
    await device.stop();
  }

  @override
  void dispose() {
    _disposed = true;
    ++_generation;
    super.dispose();
  }
}
