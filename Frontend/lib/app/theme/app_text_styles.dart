import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle _display({
    required double size,
    required FontWeight weight,
    required Color color,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  static TextStyle _body({
    required double size,
    required FontWeight weight,
    required Color color,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  static TextStyle displayLg(Color color) =>
      _display(size: 32, weight: FontWeight.w700, color: color, height: 1.15);
  static TextStyle displayMd(Color color) =>
      _display(size: 26, weight: FontWeight.w700, color: color, height: 1.2);
  static TextStyle displaySm(Color color) =>
      _display(size: 20, weight: FontWeight.w600, color: color, height: 1.25);

  static TextStyle bodyLg(Color color) =>
      _body(size: 16, weight: FontWeight.w500, color: color, height: 1.4);
  static TextStyle bodyMd(Color color) =>
      _body(size: 14, weight: FontWeight.w400, color: color, height: 1.4);
  static TextStyle bodySm(Color color) =>
      _body(size: 12, weight: FontWeight.w400, color: color, height: 1.35);

  static TextStyle label(Color color) => _body(
        size: 13,
        weight: FontWeight.w600,
        color: color,
        letterSpacing: 0.2,
      );

  static TextStyle caption(Color color) =>
      _body(size: 11, weight: FontWeight.w500, color: color, height: 1.3);

  static TextStyle button(Color color) => _body(
        size: 15,
        weight: FontWeight.w600,
        color: color,
        letterSpacing: 0.1,
      );

  static TextStyle get heading => displayMd(AppColors.charcoal);
  static TextStyle get body => bodyMd(AppColors.charcoal);
  static TextStyle get caption2 => caption(AppColors.grey500);
}
