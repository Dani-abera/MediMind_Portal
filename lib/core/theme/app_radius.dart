import 'package:flutter/material.dart';

abstract class AppRadius {
  static const double xs = 2.0;
  static const double sm = 4.0;
  static const double md = 6.0;
  static const double base = 8.0;
  static const double lg = 10.0;
  static const double xl = 12.0;
  static const double xl2 = 16.0;
  static const double full = 9999.0;

  static const BorderRadius radiusXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius radiusMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius radiusBase = BorderRadius.all(Radius.circular(base));
  static const BorderRadius radiusLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius radiusXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius radiusXl2 = BorderRadius.all(Radius.circular(xl2));
  static const BorderRadius radiusFull = BorderRadius.all(Radius.circular(full));
}
