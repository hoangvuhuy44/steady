import 'package:flutter/material.dart';

import '../theme/steady_spacing.dart';

import '../l10n/formatters.dart';
import '../l10n/nutrition_localizations.dart';
import '../nutrition/nutrition_profile.dart';
import '../nutrition/nutrition_targets.dart';

class NutritionSummaryCard extends StatelessWidget {
  const NutritionSummaryCard({super.key, required this.profile});
  final NutritionProfile profile;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final s = profile.strategy;
    if (s == null) return const SizedBox.shrink();
    final t = NutritionTargets.estimate(profile);
    final reason = NutritionTargets.unavailableReason(profile);
    return Card(
      child: Padding(
        padding: SteadySpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.nutritionConfiguration,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: SteadySpacing.md),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final option in [
                  s.goal,
                  s.energy,
                  s.macros,
                  s.source,
                  s.pattern,
                  s.timing,
                ])
                  Chip(label: Text(l.nutritionOption(option))),
              ],
            ),
            const SizedBox(height: SteadySpacing.md),
            Text(
              '${l.height}: ${l.number(profile.height)} cm · ${l.weight}: ${l.number(profile.weight)} kg',
            ),
            Text(
              '${l.nutritionBodyFat}: ${profile.bodyFat == null ? l.unknown : '${l.number(profile.bodyFat!)}%'}',
            ),
            if (t == null) ...[
              const SizedBox(height: SteadySpacing.md),
              Text(
                l.nutritionMessage(reason ?? 'nutritionEstimateUnavailable'),
              ),
            ] else ...[
              const SizedBox(height: SteadySpacing.lg),
              Text(
                '${l.nutritionMaintenanceEstimate}: ~${l.number(t.maintenance.round())} kcal',
              ),
              Text(
                '${l.nutritionDailyTarget}: ~${l.number(t.kcal.round())} kcal',
              ),
              Text(
                '${l.protein}: ~${l.grams(t.protein.round())} · ${l.nutritionCarbs}: ~${l.grams(t.carbs.round())} · ${l.nutritionFat}: ~${l.grams(t.fat.round())}',
              ),
              Text(
                '${l.nutritionSodium}: ≤${l.number(t.sodiumLimit.round())} mg · ${l.fibre}: ≥${l.grams(25)}',
              ),
              Text(
                '${l.saturatedFat}: ≤${l.grams(t.saturatedFatLimit.round())}',
              ),
              const SizedBox(height: SteadySpacing.sm),
              for (final note in t.notes)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(l.nutritionMessage(note)),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
