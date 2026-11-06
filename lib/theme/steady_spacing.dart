import 'package:flutter/material.dart';

abstract final class SteadySpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const xxxl = 48.0;
  static const display = 64.0;
  static const screen = EdgeInsets.fromLTRB(xl, lg, xl, xxl);
  static const card = EdgeInsets.all(xl);
}
