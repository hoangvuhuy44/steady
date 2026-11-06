import 'package:flutter/material.dart';

abstract final class SteadyMotion {
  static const duration = Duration(milliseconds: 220);
  static const curve = Curves.easeOut;

  static Duration durationOf(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context) ||
          MediaQuery.accessibleNavigationOf(context)
      ? Duration.zero
      : duration;
}
