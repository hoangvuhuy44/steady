import 'package:flutter/material.dart';

import '../l10n/formatters.dart';

import '../state/steady_store.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key, required this.store});

  final SteadyStore store;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l = context.l10n;

    final rewards = [
      (l.recoveryDay, 100, Icons.spa_outlined),
      (l.partnerPerk, 250, Icons.local_offer_outlined),
      (l.steadyBadge, 500, Icons.workspace_premium_outlined),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        Text(
          l.rewards,
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Text(
          l.rewardsIntro,
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 22),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.stars_rounded, size: 34, color: colors.primary),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${store.points}',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      Text(
                        l.steadyPoints,
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          l.previewRewards,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Text(l.rewardsNote, style: TextStyle(color: colors.onSurfaceVariant)),
        const SizedBox(height: 12),
        ...rewards.map(
          (reward) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                leading: CircleAvatar(
                  backgroundColor: colors.primaryContainer,
                  child: Icon(reward.$3, color: colors.onPrimaryContainer),
                ),
                title: Text(
                  reward.$1,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(l.pointsValue(reward.$2)),
                trailing: Icon(
                  store.points >= reward.$2
                      ? Icons.lock_open_outlined
                      : Icons.lock_outline,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
