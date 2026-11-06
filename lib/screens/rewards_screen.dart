import 'package:flutter/material.dart';

import '../theme/steady_spacing.dart';

import '../l10n/formatters.dart';

import '../state/steady_store.dart';
import '../widgets/activity_status.dart';
import '../widgets/brand/steady_section_header.dart';
import '../widgets/brand/steady_progress.dart';

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
      padding: SteadySpacing.screen,
      children: [
        ActivityStatus(store: store),
        SteadySectionHeader(
          title: l.rewards,
          subtitle: l.rewardsIntro,
          icon: SteadyBrandIcon.progress,
        ),
        const SizedBox(height: SteadySpacing.xl),
        Card(
          child: Padding(
            padding: SteadySpacing.card,
            child: Row(
              children: [
                Icon(Icons.stars_rounded, size: 34, color: colors.primary),
                const SizedBox(width: SteadySpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${store.points}',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
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
        const SizedBox(height: SteadySpacing.xl),
        Text(
          l.previewRewards,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: SteadySpacing.md),
        Text(l.rewardsNote, style: TextStyle(color: colors.onSurfaceVariant)),
        const SizedBox(height: SteadySpacing.md),
        ...rewards.map(
          (reward) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: Column(
                children: [
                  ListTile(
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      SteadySpacing.xl,
                      0,
                      SteadySpacing.xl,
                      SteadySpacing.lg,
                    ),
                    child: SteadyProgressBar(
                      value: (store.points / reward.$2).clamp(0, 1),
                      semanticLabel:
                          '${reward.$1}: ${l.pointsValue(store.points)} / ${l.pointsValue(reward.$2)}',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
