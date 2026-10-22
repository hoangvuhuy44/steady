import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MenuDocument {
  const MenuDocument(this.revision, this.data);
  final int revision;
  final Map<String, dynamic> data;
}

abstract class MenuRepository {
  Future<MenuDocument> load();
  Future<MenuDocument> save(Map<String, dynamic> data, int expectedRevision);
}

/// Guest preferences never migrate into an account. Account data is not cached
/// in shared preferences, and the server enforces ownership independently.
class GuestMenuRepository implements MenuRepository {
  static const key = 'steady.guest.food.v1';
  @override
  Future<MenuDocument> load() async {
    final raw = (await SharedPreferences.getInstance()).getString(key);
    if (raw == null) return const MenuDocument(0, {});
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return MenuDocument(
      json['revision'] as int,
      json['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<MenuDocument> save(
    Map<String, dynamic> data,
    int expectedRevision,
  ) async {
    final current = await load();
    if (current.revision != expectedRevision) {
      throw StateError('Menu changed; reload');
    }
    final next = MenuDocument(expectedRevision + 1, data);
    final saved = await (await SharedPreferences.getInstance()).setString(
      key,
      jsonEncode({'revision': next.revision, 'data': data}),
    );
    if (!saved) throw StateError('Menu was not saved');
    return next;
  }
}

class SupabaseMenuRepository implements MenuRepository {
  SupabaseMenuRepository(this.client, this.owner);
  final SupabaseClient client;
  final String owner;
  void _checkOwner() {
    if (client.auth.currentUser?.id != owner) {
      throw StateError('Session changed');
    }
  }

  @override
  Future<MenuDocument> load() async {
    _checkOwner();
    final row = await client
        .from('food_personalization')
        .select('revision,data')
        .eq('user_id', owner)
        .maybeSingle();
    _checkOwner();
    return row == null
        ? const MenuDocument(0, {})
        : MenuDocument(
            row['revision'] as int,
            row['data'] as Map<String, dynamic>,
          );
  }

  @override
  Future<MenuDocument> save(
    Map<String, dynamic> data,
    int expectedRevision,
  ) async {
    _checkOwner();
    final revision = await client.rpc(
      'food_personalization_save',
      params: {
        'document': data,
        'expected_revision': expectedRevision,
        'expected_owner': owner,
      },
    ) as int;
    _checkOwner();
    return MenuDocument(revision, data);
  }
}
