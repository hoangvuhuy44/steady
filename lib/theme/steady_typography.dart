import 'package:flutter/material.dart';

import 'steady_colors.dart';

abstract final class SteadyTypography {
  static TextStyle heading(
    double size, {
    FontWeight weight = FontWeight.w600,
  }) => TextStyle(
    fontFamily: 'Sora',
    // The supplied Sora lacks Vietnamese tone/horn glyphs. Keep its headings
    // and render unsupported characters with the supplied Inter font.
    fontFamilyFallback: const ['Inter'],
    fontSize: size,
    fontWeight: weight,
    height: 1.2,
    color: SteadyColors.ink,
  );

  static TextStyle body(double size, {FontWeight weight = FontWeight.w400}) =>
      TextStyle(
        fontFamily: 'Inter',
        fontSize: size,
        fontWeight: weight,
        height: size >= 16 ? 1.5 : 1.4,
        color: SteadyColors.ink,
      );

  static TextTheme get textTheme => TextTheme(
    displayLarge: heading(64, weight: FontWeight.w700),
    displayMedium: heading(56, weight: FontWeight.w700),
    displaySmall: heading(48, weight: FontWeight.w700),
    headlineLarge: heading(36, weight: FontWeight.w700),
    headlineMedium: heading(28, weight: FontWeight.w700),
    headlineSmall: heading(24),
    titleLarge: heading(20),
    titleMedium: heading(16),
    titleSmall: heading(14),
    bodyLarge: body(18),
    bodyMedium: body(16),
    bodySmall: body(14),
    labelLarge: body(16, weight: FontWeight.w600),
    labelMedium: body(14, weight: FontWeight.w500),
    labelSmall: body(12, weight: FontWeight.w500),
  );
}
