import 'package:flutter/material.dart';

abstract final class SteadyRadii {
  static const control = 12.0;
  static const card = 24.0;
  static const pill = 999.0;
  static const controlBorder = BorderRadius.all(Radius.circular(control));
  static const cardBorder = BorderRadius.all(Radius.circular(card));
  static const pillBorder = BorderRadius.all(Radius.circular(pill));
}
