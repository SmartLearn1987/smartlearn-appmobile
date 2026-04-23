import 'package:flutter/material.dart';

/// Extension on [TextStyle] for convenient font weight and style modifiers.
///
/// Usage:
/// ```dart
/// Text('Hello', style: AppTypography.bodyMedium.bold)
/// Text('Hello', style: AppTypography.h3.semiBold.italic)
/// Text('Hello', style: AppTypography.caption.medium.withColor(AppColors.accent))
/// ```
extension TextStyleExtensions on TextStyle {
  // ─── Font Weight ───

  /// FontWeight.w100
  TextStyle get thin => copyWith(fontWeight: FontWeight.w100);

  /// FontWeight.w200
  TextStyle get extraLight => copyWith(fontWeight: FontWeight.w200);

  /// FontWeight.w300
  TextStyle get light => copyWith(fontWeight: FontWeight.w300);

  /// FontWeight.w400
  TextStyle get regular => copyWith(fontWeight: FontWeight.w400);

  /// FontWeight.w500
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);

  /// FontWeight.w600
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);

  /// FontWeight.w700
  TextStyle get bold => copyWith(fontWeight: FontWeight.w700);

  /// FontWeight.w800
  TextStyle get extraBold => copyWith(fontWeight: FontWeight.w800);

  /// FontWeight.w900
  TextStyle get black => copyWith(fontWeight: FontWeight.w900);

  // ─── Font Style ───

  /// Italic style.
  TextStyle get italic => copyWith(fontStyle: FontStyle.italic);

  // ─── Text Decoration ───

  /// Underline decoration.
  TextStyle get underline => copyWith(decoration: TextDecoration.underline);

  /// Line-through decoration.
  TextStyle get lineThrough =>
      copyWith(decoration: TextDecoration.lineThrough);

  // ─── Color ───

  /// Apply a specific [color].
  TextStyle withColor(Color color) => copyWith(color: color);

  // ─── Font Size ───

  /// Apply a specific [size].
  TextStyle withSize(double size) => copyWith(fontSize: size);

  // ─── Line Height ───

  /// Apply a specific line [height] multiplier.
  TextStyle withHeight(double height) => copyWith(height: height);

  // ─── Letter Spacing ───

  /// Apply a specific [spacing] between letters.
  TextStyle withLetterSpacing(double spacing) =>
      copyWith(letterSpacing: spacing);
}
