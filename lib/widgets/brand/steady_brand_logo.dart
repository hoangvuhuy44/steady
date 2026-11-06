import 'package:flutter/material.dart';

import '../../theme/steady_spacing.dart';

enum SteadyLogoVariant { horizontal, symbol, whiteHorizontal, whiteSymbol }

/// Approved PNG masters; never recreate, tint, rotate or stretch the logo.
class SteadyBrandLogo extends StatelessWidget {
  const SteadyBrandLogo({
    super.key,
    this.variant = SteadyLogoVariant.horizontal,
    this.width = 240,
  });
  final SteadyLogoVariant variant;
  final double width;

  @override
  Widget build(BuildContext context) {
    final asset = switch (variant) {
      SteadyLogoVariant.horizontal => 'steady-horizontal-ink-outlined',
      SteadyLogoVariant.whiteHorizontal => 'steady-horizontal-white-outlined',
      SteadyLogoVariant.symbol => 'steady-symbol-gradient',
      SteadyLogoVariant.whiteSymbol => 'steady-symbol-white',
    };
    final horizontal =
        variant == SteadyLogoVariant.horizontal ||
        variant == SteadyLogoVariant.whiteHorizontal;
    return Semantics(
      label: 'Steady',
      image: true,
      child: Padding(
        padding: const EdgeInsets.all(SteadySpacing.sm),
        child: Image.asset(
          'assets/brand/logo/$asset.png',
          width: width,
          height: horizontal ? width * 300 / 1040 : width * 1360 / 1160,
          fit: BoxFit.contain,
          excludeFromSemantics: true,
        ),
      ),
    );
  }
}
