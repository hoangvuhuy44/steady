import 'dart:async';

import 'package:flutter/foundation.dart';

import 'daily_menu_engine.dart';
import 'food_catalog.dart';
import 'food_profile.dart';
import 'menu_repository.dart';

class DailyMenuController extends ChangeNotifier {
  DailyMenuController({
    required this.repository,
    List<FoodRecipe>? catalog,
    DateTime Function()? now,
  }) : catalog = catalog ?? foodCatalog,
       _now = now ?? DateTime.now;
  final MenuRepository repository;
  final List<FoodRecipe> catalog;
  final DateTime Function() _now;
  MenuDocument _document = const MenuDocument(0, {});
  FoodProfile? profile;
  List<String?> _ids = [null, null, null];
  bool busy = false, loaded = false, _disposed = false;
  Object? error;
  String? _day;
  Timer? _dayTimer;
  Set<String> rejected = {};

  List<FoodRecipe?> get menu {
    // Always revalidate on read, including a catalogue changed by an app update.
    if (busy || error != null || profile == null || _day != dayKey) {
      return [null, null, null];
    }
    return List.generate(3, (slot) {
      final recipes = catalog.where(
        (r) =>
            r.id == _ids[slot] &&
            r.meal.slot == dailySlots[slot] &&
            DailyMenuEngine.eligible(r, profile!, rejected),
      );
      return recipes.isEmpty ? null : recipes.first;
    });
  }

  String get dayKey => profile == null
      ? ''
      : '${profile!.zoneKey(_now())}/${profile!.dateKey(_now())}';
  String get localDate => profile?.dateKey(_now()) ?? '';
  Map<String, dynamic> get _plans =>
      Map<String, dynamic>.from(_document.data['plans'] as Map? ?? {});

  Set<String> _recent(FoodProfile p) {
    final date = DateTime.parse('${p.dateKey(_now())}T00:00:00Z');
    final dates = {
      for (var i = 1; i <= 2; i++)
        date.subtract(Duration(days: i)).toIso8601String().substring(0, 10),
    };
    return _plans.entries
        .where((e) => dates.contains(e.key.split('/').last))
        .expand((e) => (e.value as List).whereType<String>())
        .toSet();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> refresh() async {
    if (busy || _disposed) return;
    busy = true;
    error = null;
    _ids = [null, null, null];
    _notify();
    try {
      _document = await repository.load();
      if (_disposed) return;
      final raw = _document.data['profile'];
      profile = raw == null
          ? null
          : FoodProfile.fromJson(Map<String, dynamic>.from(raw as Map));
      rejected = (_document.data['rejected'] as List? ?? [])
          .cast<String>()
          .toSet();
      if (profile != null) await _prepare(profile!);
      loaded = true;
    } catch (e) {
      if (!_disposed) error = e;
    } finally {
      if (!_disposed) {
        busy = false;
        _notify();
      }
    }
  }

  Future<void> ensureDay() async {
    if (loaded && profile != null && _day != dayKey) await refresh();
  }

  Future<void> _prepare(FoodProfile p, {bool saveProfile = false}) async {
    final key = '${p.zoneKey(_now())}/${p.dateKey(_now())}';
    final plans = _plans;
    final raw = plans[key] as List?;
    var ids = raw == null
        ? <String?>[null, null, null]
        : raw.cast<String?>().toList();
    if (ids.length != 3) throw const FormatException('Invalid menu slots');
    for (var slot = 0; slot < 3; slot++) {
      if (!catalog.any(
        (r) =>
            r.id == ids[slot] &&
            r.meal.slot == dailySlots[slot] &&
            DailyMenuEngine.eligible(r, p, rejected),
      )) {
        ids[slot] = null;
      }
    }
    // Repair invalid slots individually; an allergy edit does not shuffle valid
    // meals. Saved empty slots remain empty on reload until an explicit change.
    if (raw == null) {
      ids = DailyMenuEngine.generate(catalog, p, rejected, _recent(p));
    } else {
      for (var slot = 0; slot < 3; slot++) {
        if (raw[slot] != null && ids[slot] == null) {
          ids = DailyMenuEngine.generate(
            catalog,
            p,
            rejected,
            _recent(p),
            fixed: ids,
            swapSlot: slot,
          );
        }
      }
      if (saveProfile) {
        for (var slot = 0; slot < 3; slot++) {
          if (ids[slot] == null) {
            ids = DailyMenuEngine.generate(
              catalog,
              p,
              rejected,
              _recent(p),
              fixed: ids,
              swapSlot: slot,
            );
          }
        }
      }
    }
    if (saveProfile || raw == null || !listEquals(raw, ids)) {
      plans[key] = ids;
      // Keep at most 35 local days; no unbounded personal history document.
      final keys = plans.keys.toList()
        ..sort((a, b) => b.split('/').last.compareTo(a.split('/').last));
      final kept = {for (final k in keys.take(35)) k: plans[k]};
      _document = await repository.save({
        'schemaVersion': 1,
        'profile': p.toJson(),
        'plans': kept,
        'rejected': rejected.toList()..sort(),
      }, _document.revision);
      if (_disposed) return;
    }
    profile = p;
    _day = key;
    _ids = ids;
    _dayTimer?.cancel();
    final instant = _now();
    final local = p.utcOffsetMinutes == null
        ? instant.toLocal()
        : instant.toUtc().add(Duration(minutes: p.utcOffsetMinutes!));
    final midnight = p.utcOffsetMinutes == null
        ? DateTime(local.year, local.month, local.day + 1)
        : DateTime.utc(local.year, local.month, local.day + 1);
    _dayTimer = Timer(midnight.difference(local), () => unawaited(refresh()));
  }

  Future<bool> saveProfile(FoodProfile value) async {
    if (busy || !loaded || _disposed) return false;
    busy = true;
    error = null;
    _notify();
    try {
      await _prepare(value, saveProfile: true);
      return !_disposed;
    } catch (e) {
      if (!_disposed) error = e;
      return false;
    } finally {
      if (!_disposed) {
        busy = false;
        _notify();
      }
    }
  }

  Future<bool> swap(int slot, {bool dislike = false}) async {
    if (slot < 0 ||
        slot > 2 ||
        busy ||
        error != null ||
        profile == null ||
        _disposed) {
      return false;
    }
    if (_day != dayKey) {
      await refresh();
      return false;
    }
    final p = profile!;
    final current = List<String?>.of(_ids);
    final nextRejected = {...rejected};
    if (dislike && current[slot] != null) nextRejected.add(current[slot]!);
    final next = DailyMenuEngine.generate(
      catalog,
      p,
      nextRejected,
      _recent(p),
      fixed: current,
      swapSlot: slot,
    );
    // A swap with no alternative retains the current dish and reports failure;
    // explicit dislike removes it even when no replacement is available.
    if (next[slot] == null && !dislike) return false;
    busy = true;
    _notify();
    try {
      final plans = _plans..[_day!] = next;
      _document = await repository.save({
        ..._document.data,
        'plans': plans,
        'rejected': nextRejected.toList()..sort(),
      }, _document.revision);
      if (_disposed) return false;
      rejected = nextRejected;
      _ids = next;
      return true;
    } catch (e) {
      if (!_disposed) error = e;
      return false;
    } finally {
      if (!_disposed) {
        busy = false;
        _notify();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _dayTimer?.cancel();
    super.dispose();
  }
}
