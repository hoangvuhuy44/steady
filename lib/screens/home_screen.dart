import 'package:flutter/material.dart';

import '../theme/steady_spacing.dart';

import '../l10n/formatters.dart';

import '../state/steady_store.dart';
import '../widgets/consistency_week.dart';
import '../widgets/metric_card.dart';
import '../widgets/activity_status.dart';
import '../widgets/activity_goal.dart';
import '../widgets/brand/steady_brand_header.dart';

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
      padding: SteadySpacing.screen,
      children: [
        ActivityStatus(store: store),
        const SteadyBrandHeader(),
        const SizedBox(height: SteadySpacing.md),
        Text(
          metrics.checkedInToday ? l.movedToday : l.makeTodayCount,
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: SteadySpacing.sm),
        Text(
          metrics.checkedInToday ? l.consistencyMessage : l.movementMessage,
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(color: colors.onSurfaceVariant, height: 1.45),
        ),
        const SizedBox(height: SteadySpacing.xl),
        Card(
          child: Padding(
            padding: SteadySpacing.card,
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
                    const SizedBox(width: SteadySpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            metrics.checkedInToday
                                ? l.checkInComplete
                                : l.noActivity,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: SteadySpacing.xs),
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
                const SizedBox(height: SteadySpacing.lg),
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
        const SizedBox(height: SteadySpacing.xl),
        Text(
          l.thisWeek,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: SteadySpacing.md),
        Row(
          children: [
            MetricCard(
              key: const ValueKey('recent-active-days'),
              icon: Icons.calendar_month_outlined,
              value: '${metrics.activeDays}/7',
              label: l.activeDays,
            ),
            const SizedBox(width: SteadySpacing.md),
            MetricCard(
              key: const ValueKey('recent-active-minutes'),
              icon: Icons.timer_outlined,
              value: '${metrics.minutes}',
              label: l.totalMovementMinutes,
            ),
          ],
        ),
        const SizedBox(height: SteadySpacing.lg),
        Card(child: ActivityGoal(metrics: metrics)),
        const SizedBox(height: SteadySpacing.md),
        Card(
          child: Padding(
            padding: SteadySpacing.card,
            child: ConsistencyWeek(metrics: metrics),
          ),
        ),
        const SizedBox(height: SteadySpacing.lg),
        Card(
          child: Padding(
            padding: SteadySpacing.card,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.local_fire_department_outlined,
                  color: colors.primary,
                ),
                const SizedBox(width: SteadySpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${metrics.streak} ${l.dayStreak}',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: SteadySpacing.sm),
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
