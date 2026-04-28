import 'package:flutter/material.dart';

/// Smart Learn Border Radius & Border Tokens
/// Extracted from design spec (smart-learn.pen)
abstract final class AppBorders {
  // ─── Radius Values ───
  static const double radiusSm = 12;
  static const double radiusMd = 14;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radiusXxl = 24;
  static const double radiusFull = 999;

  // ─── BorderRadius ───
  static const BorderRadius borderRadiusSm = BorderRadius.all(
    Radius.circular(radiusSm),
  );
  static const BorderRadius borderRadiusMd = BorderRadius.all(
    Radius.circular(radiusMd),
  );
  static const BorderRadius borderRadiusLg = BorderRadius.all(
    Radius.circular(radiusLg),
  );
  static const BorderRadius borderRadiusXl = BorderRadius.all(
    Radius.circular(radiusXl),
  );
  static const BorderRadius borderRadiusXxl = BorderRadius.all(
    Radius.circular(radiusXxl),
  );
  static const BorderRadius borderRadiusFull = BorderRadius.all(
    Radius.circular(radiusFull),
  );

  // ─── RoundedRectangleBorder (for button shapes) ───
  static const RoundedRectangleBorder shapeSm = RoundedRectangleBorder(
    borderRadius: borderRadiusSm,
  );
  static const RoundedRectangleBorder shapeMd = RoundedRectangleBorder(
    borderRadius: borderRadiusMd,
  );
  static const RoundedRectangleBorder shapeLg = RoundedRectangleBorder(
    borderRadius: borderRadiusLg,
  );
  static const RoundedRectangleBorder shapeXl = RoundedRectangleBorder(
    borderRadius: borderRadiusXl,
  );
  static const RoundedRectangleBorder shapeFull = RoundedRectangleBorder(
    borderRadius: borderRadiusFull,
  );

  // ─── Border Widths ───
  static const double widthThin = 1;
  static const double widthMedium = 1.5;
  static const double widthThick = 2;
}
