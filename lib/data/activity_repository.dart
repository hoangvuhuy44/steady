import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../models/activity_type.dart';

abstract class ActivityRepository {
  Future<String> guestOwnerId();
  Future<List<ActivityLog>> load(String ownerId);
  Future<void> insert(ActivityLog log);
  Future<void> close();
}

ActivityRepository createActivityRepository() =>
    kIsWeb ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux
    ? PreferencesActivityRepository()
    : SqliteActivityRepository();

/// LocalStorage on web and platform preferences on Windows/Linux.
/// Each activity is a separate entry, so saving never rewrites other history.
class PreferencesActivityRepository implements ActivityRepository {
  PreferencesActivityRepository({SharedPreferencesAsync? preferences})
    : _injectedPreferences = preferences;

  final SharedPreferencesAsync? _injectedPreferences;
  late final SharedPreferencesAsync _preferences =
      _injectedPreferences ?? SharedPreferencesAsync();
  static const _guestKey = 'steady.activity.v1.guest';
  static const _logPrefix = 'steady.activity.v1.log.';

  String _ownerPrefix(String ownerId) =>
      '$_logPrefix${base64Url.encode(utf8.encode(ownerId))}.';

  @override
  Future<String> guestOwnerId() async {
    final existing = await _preferences.getString(_guestKey);
    if (existing != null) return existing;
    final owner = 'guest:${const Uuid().v4()}';
    await _preferences.setString(_guestKey, owner);
    return owner;
  }

  @override
  Future<List<ActivityLog>> load(String ownerId) async {
    final prefix = _ownerPrefix(ownerId);
    final keys = await _preferences.getKeys();
    final logs = <ActivityLog>[];
    for (final key in keys.where((key) => key.startsWith(prefix))) {
      final encoded = await _preferences.getString(key);
      if (encoded == null) continue;
      final row = jsonDecode(encoded) as Map<String, dynamic>;
      final log = ActivityLog(
        id: row['id'] as String,
        ownerId: row['owner_id'] as String,
        type: ActivityType.values.byName(row['activity_type'] as String),
        minutes: row['minutes'] as int,
        createdAt: DateTime.parse(row['created_at_utc'] as String).toUtc(),
        localDate: row['local_date'] as String,
      );
      if (log.ownerId != ownerId || log.minutes <= 0) {
        throw const FormatException('Invalid stored activity');
      }
      logs.add(log);
    }
    return logs
      ..sort((a, b) {
        final time = a.createdAt.compareTo(b.createdAt);
        return time != 0 ? time : a.id.compareTo(b.id);
      });
  }

  @override
  Future<void> insert(ActivityLog log) async {
    if (log.minutes <= 0) throw ArgumentError.value(log.minutes, 'minutes');
    final key = '${_ownerPrefix(log.ownerId)}${log.id}';
    if (await _preferences.containsKey(key)) {
      throw StateError('Activity already exists');
    }
    await _preferences.setString(
      key,
      jsonEncode({
        'id': log.id,
        'owner_id': log.ownerId,
        'activity_type': log.type.name,
        'minutes': log.minutes,
        'created_at_utc': log.createdAt.toUtc().toIso8601String(),
        'local_date': log.localDate,
      }),
    );
  }

  @override
  Future<void> close() async {}
}

/// Native sqflite on Android/iOS. Tests inject an FFI database factory.
class SqliteActivityRepository implements ActivityRepository {
  SqliteActivityRepository({this._factory, this._databasePath});

  final DatabaseFactory? _factory;
  final String? _databasePath;
  Future<Database>? _opening;

  Future<Database> _database() async {
    final opening = _opening ??= _open();
    try {
      return await opening;
    } catch (_) {
      // An open failure must not poison every subsequent retry.
      if (identical(_opening, opening)) _opening = null;
      rethrow;
    }
  }

  Future<Database> _open() async {
    final factory = _factory ?? databaseFactory;
    final location =
        _databasePath ??
        path.join(await factory.getDatabasesPath(), 'steady_activities.db');
    return factory.openDatabase(
      location,
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: (db, _) async {
          await db.execute('''
            CREATE TABLE activity_logs (
              id TEXT PRIMARY KEY NOT NULL,
              owner_id TEXT NOT NULL,
              activity_type TEXT NOT NULL,
              minutes INTEGER NOT NULL CHECK (minutes > 0),
              created_at_utc TEXT NOT NULL,
              local_date TEXT NOT NULL
            )
          ''');
          await db.execute(
            'CREATE INDEX activity_owner_time '
            'ON activity_logs(owner_id, created_at_utc, id)',
          );
          await _createDeviceIdentity(db);
        },
        onUpgrade: (db, oldVersion, _) async {
          if (oldVersion < 2) await _createDeviceIdentity(db);
        },
      ),
    );
  }

  static Future<void> _createDeviceIdentity(Database db) => db.execute('''
    CREATE TABLE device_identity (
      id INTEGER PRIMARY KEY CHECK (id = 1),
      guest_owner_id TEXT NOT NULL UNIQUE
    )
  ''');

  @override
  Future<String> guestOwnerId() async {
    final db = await _database();
    return db.transaction((transaction) async {
      final rows = await transaction.query('device_identity', where: 'id = 1');
      if (rows.isNotEmpty) return rows.single['guest_owner_id'] as String;
      final owner = 'guest:${const Uuid().v4()}';
      await transaction.insert('device_identity', {
        'id': 1,
        'guest_owner_id': owner,
      });
      return owner;
    });
  }

  @override
  Future<List<ActivityLog>> load(String ownerId) async {
    final db = await _database();
    final rows = await db.query(
      'activity_logs',
      where: 'owner_id = ?',
      whereArgs: [ownerId],
      orderBy: 'created_at_utc ASC, id ASC',
    );
    return rows
        .map(
          (row) => ActivityLog(
            id: row['id'] as String,
            ownerId: row['owner_id'] as String,
            type: ActivityType.values.byName(row['activity_type'] as String),
            minutes: row['minutes'] as int,
            createdAt: row['created_at_utc'] is int
                ? DateTime.fromMicrosecondsSinceEpoch(
                    row['created_at_utc'] as int,
                    isUtc: true,
                  )
                : DateTime.parse(row['created_at_utc'] as String).toUtc(),
            localDate: row['local_date'] as String,
          ),
        )
        .toList()
      ..sort((a, b) {
        // A migrated database can contain both legacy integer and ISO timestamps.
        final time = a.createdAt.compareTo(b.createdAt);
        return time != 0 ? time : a.id.compareTo(b.id);
      });
  }

  @override
  Future<void> insert(ActivityLog log) async {
    final db = await _database();
    await db.insert('activity_logs', {
      'id': log.id,
      'owner_id': log.ownerId,
      'activity_type': log.type.name,
      'minutes': log.minutes,
      'created_at_utc': log.createdAt.toUtc().toIso8601String(),
      'local_date': log.localDate,
    });
  }

  @override
  Future<void> close() async {
    final opening = _opening;
    if (opening == null) return;
    try {
      await (await opening).close();
    } finally {
      _opening = null;
    }
  }
}
