import 'package:steady/data/activity_repository.dart';
import 'package:steady/models/activity_type.dart';

class FakeActivityRepository implements ActivityRepository {
  @override
  Future<String> guestOwnerId() async =>
      onGuestOwner != null ? await onGuestOwner!() : 'guest:test-device';

  Future<String> Function()? onGuestOwner;

  final List<ActivityLog> saved = [];
  bool failRead = false;
  bool failWrite = false;
  int writes = 0;
  Future<List<ActivityLog>> Function(String)? onLoad;
  Future<void> Function(ActivityLog)? onInsert;

  @override
  Future<List<ActivityLog>> load(String ownerId) async {
    if (onLoad != null) return onLoad!(ownerId);
    if (failRead) throw StateError('read failed');
    return saved.where((log) => log.ownerId == ownerId).toList();
  }

  @override
  Future<void> insert(ActivityLog log) async {
    writes++;
    if (onInsert != null) await onInsert!(log);
    if (failWrite) throw StateError('write failed');
    saved.add(log);
  }

  @override
  Future<void> close() async {}
}
