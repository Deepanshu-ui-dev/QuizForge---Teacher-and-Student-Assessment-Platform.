import 'package:flutter/material.dart';

class AppRadii {
  AppRadii._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;

  static BorderRadius get smRadius => BorderRadius.circular(sm);
  static BorderRadius get mdRadius => BorderRadius.circular(md);
  static BorderRadius get lgRadius => BorderRadius.circular(lg);
  static BorderRadius get xlRadius => BorderRadius.circular(xl);

  static BorderRadius get heroBottomOnly => const BorderRadius.only(
        bottomLeft: Radius.circular(xl),
        bottomRight: Radius.circular(xl),
      );
}
