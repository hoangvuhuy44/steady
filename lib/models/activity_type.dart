import 'package:flutter/material.dart';

enum ActivityType { walk, run, cycle, swim, gym, sport, mma, other }

extension ActivityTypeX on ActivityType {
  IconData get icon => switch (this) {
    ActivityType.walk => Icons.directions_walk,
    ActivityType.run => Icons.directions_run,
    ActivityType.cycle => Icons.directions_bike,
    ActivityType.swim => Icons.pool,
    ActivityType.gym => Icons.fitness_center,
    ActivityType.sport => Icons.sports_basketball,
    ActivityType.mma => Icons.sports_mma,
    ActivityType.other => Icons.more_horiz,
  };
}

class ActivityLog {
  const ActivityLog({
    required this.type,
    required this.minutes,
    required this.createdAt,
  });

  final ActivityType type;
  final int minutes;
  final DateTime createdAt;
}
