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
    required this.id,
    required this.ownerId,
    required this.type,
    required this.minutes,
    required this.createdAt,
    required this.localDate,
  });

  final String id;
  final String ownerId;
  final ActivityType type;
  final int minutes;

  /// The instant of recording, in UTC.
  final DateTime createdAt;

  /// Calendar date at the recording location; never recalculate on travel.
  final String localDate;

  static String dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
