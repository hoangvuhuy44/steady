import 'package:flutter/material.dart';

import '../theme/steady_spacing.dart';

import '../l10n/formatters.dart';
import '../state/steady_store.dart';

class ActivityStatus extends StatelessWidget {
  const ActivityStatus({super.key, required this.store});

  final SteadyStore store;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    if (store.activityLoading) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          children: [
            const LinearProgressIndicator(),
            const SizedBox(height: SteadySpacing.sm),
            Text(l.activityLoading),
          ],
        ),
      );
    }
    final readError = store.activityLoadError != null;
    if (!readError && store.activitySaveError == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            readError ? l.activityLoadError : l.activitySaveError,
            key: ValueKey(
              readError ? 'activity-load-error' : 'activity-save-error',
            ),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          if (readError)
            TextButton(
              key: const ValueKey('activity-retry'),
              onPressed: store.reloadActivities,
              child: Text(l.activityRetry),
            ),
        ],
      ),
    );
  }
}
