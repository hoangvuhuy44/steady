import 'package:flutter/material.dart';

import '../l10n/formatters.dart';

import '../state/steady_store.dart';
import '../widgets/consistency_week.dart';
import '../widgets/metric_card.dart';
import '../widgets/activity_status.dart';
import '../widgets/activity_goal.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.store, required this.onCheckIn});

  final SteadyStore store;
  final VoidCallback onCheckIn;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final metrics = store.activityMetrics;
    final latest = metrics.latestToday;
    final l = context.l10n;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        ActivityStatus(store: store),
        Text(
          'Steady',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          metrics.checkedInToday ? l.movedToday : l.makeTodayCount,
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Text(
          metrics.checkedInToday ? l.consistencyMessage : l.movementMessage,
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(color: colors.onSurfaceVariant, height: 1.45),
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: metrics.checkedInToday
                            ? colors.primaryContainer
                            : colors.secondaryContainer,
                      ),
                      child: Icon(
                        metrics.checkedInToday
                            ? Icons.check_rounded
                            : Icons.bolt_rounded,
                        color: metrics.checkedInToday
                            ? colors.onPrimaryContainer
                            : colors.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            metrics.checkedInToday
                                ? l.checkInComplete
                                : l.noActivity,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            latest == null
                                ? l.anyMovement
                                : '${l.activityName(latest.type)} · ${l.minutesValue(latest.minutes)}',
                            key: const ValueKey('today-activity-detail'),
                            style: TextStyle(color: colors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: onCheckIn,
                  icon: Icon(
                    metrics.checkedInToday ? Icons.add : Icons.check_circle,
                  ),
                  label: Text(
                    metrics.checkedInToday ? l.logAnother : l.checkIn,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        Text(
          l.thisWeek,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            MetricCard(
              key: const ValueKey('recent-active-days'),
              icon: Icons.calendar_month_outlined,
              value: '${metrics.activeDays}/7',
              label: l.activeDays,
            ),
            const SizedBox(width: 12),
            MetricCard(
              key: const ValueKey('recent-active-minutes'),
              icon: Icons.timer_outlined,
              value: '${metrics.minutes}',
              label: l.totalMovementMinutes,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(child: ActivityGoal(metrics: metrics)),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: ConsistencyWeek(metrics: metrics),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.local_fire_department_outlined,
                  color: colors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${metrics.streak} ${l.dayStreak}',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l.streakRule,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(height: 1.45),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
