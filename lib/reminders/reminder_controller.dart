import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:timezone/data/latest.dart' as data;
import 'package:timezone/timezone.dart' as tz;

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
  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'morning': morning,
    'evening': evening,
    'timezone': timezone,
  };
  bool get valid {
    data.initializeTimeZones();
    return RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(morning) &&
        RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(evening) &&
        morning != evening &&
        tz.timeZoneDatabase.locations.containsKey(timezone);
  }
}

abstract interface class ReminderApi {
  Future<ReminderSettings> load();
  Future<void> save(ReminderSettings settings);
}

class ReminderCacheEntry {
  const ReminderCacheEntry(this.settings, this.pending);
  final ReminderSettings settings;
  final bool pending;
}

abstract interface class ReminderCache {
  Future<ReminderCacheEntry?> load();
  Future<void> save(ReminderSettings settings, {required bool pending});
}

class MemoryReminderCache implements ReminderCache {
  ReminderCacheEntry? entry;
  @override
  Future<ReminderCacheEntry?> load() async => entry;
  @override
  Future<void> save(ReminderSettings settings, {required bool pending}) async {
    entry = ReminderCacheEntry(settings, pending);
  }
}

abstract interface class ReminderDevice {
  bool get supported;
  Future<ReminderPermission> permission({bool request = false});
  // Implementations serialize mutations and recheck current after native awaits.
  Future<void> schedule(ReminderSettings settings, bool Function() current);
  Future<void> test(bool Function() current);
  Future<void> stop();
}

class ReminderController extends ChangeNotifier {
  ReminderController({
    required this.api,
    required this.device,
    ReminderCache? cache,
    bool Function()? isOwner,
  }) : cache = cache ?? MemoryReminderCache(),
       _isOwner = isOwner ?? (() => true);
  final ReminderApi api;
  final ReminderDevice device;
  final ReminderCache cache;
  final bool Function() _isOwner;
  ReminderSettings settings = const ReminderSettings();
  ReminderPermission permission = ReminderPermission.unknown;
  bool busy = false, registered = false, pendingSync = false;
  bool _disposed = false, _detached = false, _cacheLoaded = false;
  Timer? _retry;
  String? error;
  bool get _current => !_disposed && !_detached && _isOwner();
  void _notify() {
    if (_current) notifyListeners();
  }

  Future<void> _persist(ReminderSettings value, bool pending) async {
    try {
      await cache.save(value, pending: pending);
    } catch (_) {
      throw const _ReminderFailure('cache');
    }
    if (!_current) return;
    settings = value;
    pendingSync = pending;
  }

  Future<void> _apply() async {
    if (!_current) return;
    registered = false;
    if (!settings.enabled) {
      try {
        await device.stop();
      } catch (_) {
        throw const _ReminderFailure('schedule');
      }
      return;
    }
    permission = device.supported
        ? await device.permission()
        : ReminderPermission.unsupported;
    if (!_current) return;
    if (permission != ReminderPermission.granted) {
      await device.stop();
      throw _ReminderFailure(device.supported ? 'permission' : 'unsupported');
    }
    try {
      await device.schedule(settings, () => _current);
      if (_current) registered = true;
    } catch (_) {
      throw const _ReminderFailure('schedule');
    }
  }

  Future<void> _sync() async {
    try {
      if (pendingSync) {
        await api.save(settings).timeout(const Duration(seconds: 12));
        if (!_current) return;
        await _persist(settings, false);
      }
      if (!_current) return;
      final remote = await api.load().timeout(const Duration(seconds: 12));
      if (!_current) return;
      if (!remote.valid) throw const _ReminderFailure('invalid');
      await _persist(remote, false);
    } on _ReminderFailure {
      rethrow;
    } catch (_) {
      throw const _ReminderFailure('sync');
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    if (busy || !_current) return;
    _retry?.cancel();
    busy = true;
    error = null;
    _notify();
    try {
      await action();
    } on _ReminderFailure catch (e) {
      if (_current) error = e.code;
    } catch (_) {
      if (_current) error = 'schedule';
    } finally {
      busy = false;
      _notify();
      if (_current && (pendingSync || error == 'sync')) {
        _retry = Timer(const Duration(seconds: 30), () => unawaited(refresh()));
      }
    }
  }

  /// Cache is applied before contacting Supabase; startup/resume never prompts.
  Future<void> refresh() => _run(() async {
    if (!_cacheLoaded) {
      ReminderCacheEntry? saved;
      try {
        saved = await cache.load();
      } catch (_) {
        throw const _ReminderFailure('cache');
      }
      if (!_current) return;
      _cacheLoaded = true;
      if (saved != null) {
        if (!saved.settings.valid) throw const _ReminderFailure('invalid');
        settings = saved.settings;
        pendingSync = saved.pending;
      }
    }
    // Still synchronize a remote disable even if local permission was revoked.
    _ReminderFailure? localError;
    try {
      await _apply();
    } on _ReminderFailure catch (e) {
      localError = e;
    }
    if (!_current) return;
    try {
      await _sync();
    } on _ReminderFailure catch (e) {
      throw localError ?? e;
    }
    if (_current) await _apply();
  });

  Future<void> _change(ReminderSettings next, {bool request = false}) =>
      _run(() async {
        if (!next.valid) throw const _ReminderFailure('invalid');
        if (next.enabled) {
          if (!device.supported) throw const _ReminderFailure('unsupported');
          permission = await device.permission(request: request);
          if (!_current) return;
          if (permission != ReminderPermission.granted) {
            registered = false;
            await device.stop();
            throw const _ReminderFailure('permission');
          }
        } else {
          // Cancel even if local storage or network is unavailable.
          try {
            await device.stop();
          } catch (_) {
            throw const _ReminderFailure('schedule');
          }
          registered = false;
        }
        if (!_current) return;
        await _persist(next, true);
        if (!_current) return;
        _cacheLoaded = true;
        await _apply();
        if (_current) await _sync();
        if (_current) await _apply();
      });
  Future<void> enable(ReminderSettings draft) => _change(
    ReminderSettings(
      enabled: true,
      morning: draft.morning,
      evening: draft.evening,
      timezone: draft.timezone.trim(),
    ),
    request: true,
  );
  Future<void> save(ReminderSettings draft) => _change(
    ReminderSettings(
      enabled: settings.enabled,
      morning: draft.morning,
      evening: draft.evening,
      timezone: draft.timezone.trim(),
    ),
  );
  Future<void> disable() => _change(
    ReminderSettings(
      morning: settings.morning,
      evening: settings.evening,
      timezone: settings.timezone,
    ),
  );
  Future<bool> test() async {
    var shown = false;
    await _run(() async {
      if (!device.supported) throw const _ReminderFailure('unsupported');
      permission = await device.permission(request: true);
      if (!_current) return;
      if (permission != ReminderPermission.granted) {
        throw const _ReminderFailure('permission');
      }
      await device.test(() => _current);
      shown = _current;
    });
    return shown;
  }

  Future<void> detach() async {
    _detached = true;
    _retry?.cancel();
    registered = false;
    await device.stop();
  }

  @override
  void dispose() {
    _disposed = true;
    _retry?.cancel();
    super.dispose();
  }
}

class _ReminderFailure implements Exception {
  const _ReminderFailure(this.code);
  final String code;
}
