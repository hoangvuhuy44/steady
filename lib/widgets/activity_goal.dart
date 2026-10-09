import 'package:flutter/material.dart';

import '../l10n/formatters.dart';
import '../models/activity_metrics.dart';
import 'brand/steady_progress.dart';

/// Shared goal wording and progress on Home and Profile.
class ActivityGoal extends StatelessWidget {
  const ActivityGoal({super.key, required this.metrics});

  final ActivityMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return ListTile(
      leading: SteadyProgressRing(
        value: (metrics.activeDays / ActivityMetrics.targetDays).clamp(0, 1),
        semanticLabel: l.activeDaysProgress(metrics.activeDays),
        child: Icon(
          metrics.targetReached ? Icons.check_rounded : Icons.flag_outlined,
          size: 20,
        ),
      ),
      title: Text(l.fiveDays),
      subtitle: Text(
        '${l.activeDaysProgress(metrics.activeDays)} · '
        '${metrics.targetReached ? l.activityTargetReached : l.activityTargetInProgress}',
      ),
    );
  }
}
