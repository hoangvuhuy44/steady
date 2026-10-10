import 'package:flutter/material.dart';

import '../../theme/steady_spacing.dart';

enum SteadyBrandIcon { activity, progress, wellness, consistency }

/// Supporting graphics are decorative; the heading carries the meaning.
class SteadySectionHeader extends StatelessWidget {
  const SteadySectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
  });
  final String title;
  final String? subtitle;
  final SteadyBrandIcon icon;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'assets/brand/icons/icon-${icon.name}.png',
            width: 44,
            height: 44,
            excludeFromSemantics: true,
          ),
          const SizedBox(width: SteadySpacing.md),
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
        ],
      ),
      if (subtitle != null) ...[
        const SizedBox(height: SteadySpacing.sm),
        Text(
          subtitle!,
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    ],
  );
}
