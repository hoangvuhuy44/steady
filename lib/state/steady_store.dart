import 'package:flutter/foundation.dart';

import '../models/activity_type.dart';

class SteadyStore extends ChangeNotifier {
  final List<ActivityLog> _logs = [];
  int _points = 120;
  int _streak = 3;

  List<ActivityLog> get logs => List.unmodifiable(_logs);
  int get points => _points;
  int get streak => _streak;

  bool get checkedInToday {
    final now = DateTime.now();
    return _logs.any(
      (log) =>
          log.createdAt.year == now.year &&
          log.createdAt.month == now.month &&
          log.createdAt.day == now.day,
    );
  }

  ActivityLog? get latestLog => _logs.isEmpty ? null : _logs.last;

  void logActivity(ActivityType type, int minutes) {
    final wasCheckedIn = checkedInToday;

    _logs.add(
      ActivityLog(
        type: type,
        minutes: minutes,
        createdAt: DateTime.now(),
      ),
    );

    if (!wasCheckedIn) {
      _points += 20;
      _streak += 1;
    } else {
      _points += 5;
    }

    notifyListeners();
  }
}
