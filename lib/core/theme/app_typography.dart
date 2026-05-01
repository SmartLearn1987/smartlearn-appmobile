import 'package:flutter/material.dart';

/// Smart Learn Typography Tokens
/// Font: Quicksand (Google Fonts)
abstract final class AppTypography {
  static String get _fontFamily => 'Quicksand';

  // ─── Headings ───
  static TextStyle get h1 => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static TextStyle get h2 => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static TextStyle get h3 => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static TextStyle get h4 => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // ─── Body ───
  static TextStyle get bodyLarge => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static TextStyle get bodyMedium => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle get bodySmall => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // ─── Labels ───
  static TextStyle get labelLarge => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static TextStyle get labelMedium => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static TextStyle get labelSmall => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  // ─── Caption ───
  static TextStyle get caption => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  // ─── Button ───
  static TextStyle get buttonLarge => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.0,
  );

  static TextStyle get buttonMedium => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.0,
  );

  static TextStyle get buttonSmall => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.0,
  );

  static TextStyle get text3Xl =>
      TextStyle(fontFamily: _fontFamily, fontSize: 30, height: 1.2);
  static TextStyle get text2Xl =>
      TextStyle(fontFamily: _fontFamily, fontSize: 24, height: 1.2);
  static TextStyle get textXl =>
      TextStyle(fontFamily: _fontFamily, fontSize: 20, height: 1.2);
  static TextStyle get textLg =>
      TextStyle(fontFamily: _fontFamily, fontSize: 18, height: 1.2);
  static TextStyle get textBase =>
      TextStyle(fontFamily: _fontFamily, fontSize: 16, height: 1.2);
  static TextStyle get textSm =>
      TextStyle(fontFamily: _fontFamily, fontSize: 14, height: 1.2);
  static TextStyle get textXs =>
      TextStyle(fontFamily: _fontFamily, fontSize: 12, height: 1.2);
  static TextStyle get text2Xs =>
      TextStyle(fontFamily: _fontFamily, fontSize: 10, height: 1.2);
}
