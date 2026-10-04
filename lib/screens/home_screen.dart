import 'package:flutter/material.dart';

import '../l10n/formatters.dart';

import '../state/steady_store.dart';
import '../widgets/consistency_week.dart';
import '../widgets/metric_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.store, required this.onCheckIn});

  final SteadyStore store;
  final VoidCallback onCheckIn;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final latest = store.latestLog;
    final l = context.l10n;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
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
          store.checkedInToday ? l.movedToday : l.makeTodayCount,
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Text(
          store.checkedInToday ? l.consistencyMessage : l.movementMessage,
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
                        color: store.checkedInToday
                            ? colors.primaryContainer
                            : colors.secondaryContainer,
                      ),
                      child: Icon(
                        store.checkedInToday
                            ? Icons.check_rounded
                            : Icons.bolt_rounded,
                        color: store.checkedInToday
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
                            store.checkedInToday
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
                    store.checkedInToday ? Icons.add : Icons.check_circle,
                  ),
                  label: Text(store.checkedInToday ? l.logAnother : l.checkIn),
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
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: ConsistencyWeek(logs: store.logs),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            MetricCard(
              icon: Icons.local_fire_department_outlined,
              value: '${store.streak}',
              label: l.dayStreak,
            ),
            const SizedBox(width: 12),
            MetricCard(
              icon: Icons.stars_outlined,
              value: '${store.points}',
              label: l.steadyPoints,
            ),
          ],
        ),
        const SizedBox(height: 22),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline, color: colors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l.consistencyTip,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(height: 1.45),
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
