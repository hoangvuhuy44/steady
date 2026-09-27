import 'package:flutter/material.dart';

class ConsistencyWeek extends StatelessWidget {
  const ConsistencyWeek({
    super.key,
    required this.checkedInToday,
  });

  final bool checkedInToday;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final colors = Theme.of(context).colorScheme;

    // Placeholder demo history for the first MVP.
    // Replace this with real persisted activity data later.
    final completed = <bool>[
      true,
      true,
      false,
      true,
      true,
      true,
      checkedInToday,
    ];

    final dayNames = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
      return labels[date.weekday - 1];
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final done = completed[index];

        return Column(
          children: [
            Text(
              dayNames[index],
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? colors.primary : colors.surfaceContainerHighest,
              ),
              child: Icon(
                done ? Icons.check : Icons.remove,
                size: 18,
                color: done ? colors.onPrimary : colors.onSurfaceVariant,
              ),
            ),
          ],
        );
      }),
    );
  }
}
