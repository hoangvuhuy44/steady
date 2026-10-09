import 'package:flutter/material.dart';

import '../l10n/formatters.dart';
import '../models/activity_metrics.dart';

/// Shared goal wording and progress on Home and Profile.
class ActivityGoal extends StatelessWidget {
  const ActivityGoal({super.key, required this.metrics});

  final ActivityMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return ListTile(
      leading: const Icon(Icons.flag_outlined),
      title: Text(l.fiveDays),
      subtitle: Text(
        '${l.activeDaysProgress(metrics.activeDays)} · '
        '${metrics.targetReached ? l.activityTargetReached : l.activityTargetInProgress}',
      ),
    );
  }
}
