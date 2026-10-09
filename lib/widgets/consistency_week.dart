import 'package:flutter/material.dart';

import '../l10n/formatters.dart';
import '../models/activity_metrics.dart';

class ConsistencyWeek extends StatelessWidget {
  const ConsistencyWeek({super.key, required this.metrics});

  final ActivityMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final days = metrics.days;
    final completed = days.map(metrics.isActiveOn).toList();

    final dayNames = List.generate(7, (index) {
      final date = days[index];
      final labels = context.l10n.weekdays;
      return labels[date.weekday - 1];
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final done = completed[index];

        return Expanded(
          child: Semantics(
            label:
                '${dayNames[index]}: ${done ? context.l10n.completed : context.l10n.notCompleted}',
            child: Column(
              children: [
                Text(
                  dayNames[index],
                  style: Theme.of(context).textTheme.labelMedium
                      ?.copyWith(color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done
                        ? colors.primary
                        : colors.surfaceContainerHighest,
                  ),
                  child: Icon(
                    done ? Icons.check : Icons.remove,
                    size: 18,
                    color: done ? colors.onPrimary : colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
