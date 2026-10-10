import 'package:flutter/material.dart';

import 'steady_colors.dart';

abstract final class SteadyGradients {
  static const progressColors = [
    SteadyColors.freshMint,
    SteadyColors.aquaTeal,
    SteadyColors.flowCyan,
    SteadyColors.momentumBlue,
    SteadyColors.deepCoreBlue,
  ];
  static const progress = LinearGradient(colors: progressColors);
  static const ring = SweepGradient(
    startAngle: -1.5707963267948966,
    endAngle: 4.71238898038469,
    colors: progressColors,
  );
}
