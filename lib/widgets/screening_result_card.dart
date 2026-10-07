import 'package:flutter/material.dart';

import '../l10n/formatters.dart';
import '../l10n/screening_localizations.dart';
import '../screening/health_screening.dart';

class ScreeningResultCard extends StatelessWidget {
  const ScreeningResultCard({super.key, this.assessment});
  final ScreeningAssessment? assessment;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final a = assessment;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              a?.allowsSamplePlan == true
                  ? Icons.check_circle_outline
                  : Icons.health_and_safety_outlined,
              size: 36,
            ),
            const SizedBox(height: 12),
            Text(
              a == null ? l.screeningPaused : l.decisionName(a.decision),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (a == null)
              Text(l.screeningDeclined)
            else
              for (final reason in a.reasons)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(l.screeningReason(reason)),
                ),
            const SizedBox(height: 8),
            if (a != null && a.guidance.isNotEmpty) ...[
              Text(
                l.screeningGuidance,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              for (final tip in a.guidance)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tip == 'diabetes'
                            ? l.screeningTipDiabetes
                            : l.screeningTipSodium,
                      ),
                      const SizedBox(height: 6),
                      SelectableText(
                        tip == 'diabetes'
                            ? 'NIDDK: https://www.niddk.nih.gov/health-information/diabetes/overview/healthy-living-with-diabetes'
                            : 'AHA: https://www.heart.org/en/healthy-living/healthy-eating/eat-smart/sodium/how-to-reduce-sodium',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              Text(l.screeningSources),
              const SizedBox(height: 12),
            ],
            Text(l.screeningNote),
          ],
        ),
      ),
    );
  }
}
