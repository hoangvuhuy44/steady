import 'package:flutter/material.dart';

import '../../l10n/formatters.dart';
import '../../theme/steady_colors.dart';
import '../../theme/steady_radii.dart';
import '../../theme/steady_spacing.dart';
import 'steady_brand_logo.dart';

class SteadyBrandHeader extends StatelessWidget {
  const SteadyBrandHeader({super.key});

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: SteadyColors.white,
      borderRadius: SteadyRadii.cardBorder,
      image: DecorationImage(
        image: AssetImage('assets/brand/visuals/background-light-minimal.png'),
        fit: BoxFit.cover,
      ),
    ),
    padding: const EdgeInsets.all(SteadySpacing.sm),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SteadyBrandLogo(),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            SteadySpacing.sm,
            0,
            SteadySpacing.sm,
            SteadySpacing.sm,
          ),
          child: Text(
            context.l10n.brandSlogan,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    ),
  );
}
