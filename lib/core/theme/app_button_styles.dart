import 'package:flutter/material.dart';
import 'app_borders.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Smart Learn Button Style Tokens
abstract final class AppButtonStyles {
  // ─── Primary Button ───
  static ButtonStyle get primary => ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.primaryForeground,
    textStyle: AppTypography.buttonLarge,
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.smMd,
    ),
    minimumSize: const Size(0, 44),
    shape: AppBorders.shapeSm,
    elevation: 0,
  );

  // ─── Secondary Button ───
  static ButtonStyle get secondary => ElevatedButton.styleFrom(
    backgroundColor: AppColors.secondary,
    foregroundColor: AppColors.secondaryForeground,
    textStyle: AppTypography.buttonLarge,
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.smMd,
    ),
    minimumSize: const Size(0, 44),
    shape: AppBorders.shapeSm,
    elevation: 0,
  );

  // ─── Accent Button ───
  static ButtonStyle get accent => ElevatedButton.styleFrom(
    backgroundColor: AppColors.accent,
    foregroundColor: AppColors.accentForeground,
    textStyle: AppTypography.buttonLarge,
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.smMd,
    ),
    minimumSize: const Size(0, 44),
    shape: AppBorders.shapeSm,
    elevation: 0,
  );

  // ─── Outline Button ───
  static ButtonStyle get outline => OutlinedButton.styleFrom(
    foregroundColor: AppColors.foreground,
    textStyle: AppTypography.buttonLarge,
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.smMd,
    ),
    minimumSize: const Size(0, 44),
    shape: RoundedRectangleBorder(
      borderRadius: AppBorders.borderRadiusSm,
      side: const BorderSide(
        color: AppColors.border,
        width: AppBorders.widthThin,
      ),
    ),
    side: const BorderSide(
      color: AppColors.border,
      width: AppBorders.widthThin,
    ),
  );

  // ─── Ghost / Text Button ───
  static ButtonStyle get ghost => TextButton.styleFrom(
    foregroundColor: AppColors.primary,
    textStyle: AppTypography.buttonMedium,
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
    minimumSize: const Size(0, 36),
    shape: AppBorders.shapeSm,
  );

  // ─── Destructive Button ───
  static ButtonStyle get destructive => ElevatedButton.styleFrom(
    backgroundColor: AppColors.destructive,
    foregroundColor: AppColors.destructiveForeground,
    textStyle: AppTypography.buttonLarge,
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.smMd,
    ),
    minimumSize: const Size(0, 44),
    shape: AppBorders.shapeSm,
    elevation: 0,
  );

  // ─── Soft / Tinted Buttons ───
  static ButtonStyle primarySoft({double height = 36}) =>
      ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.primary,
        textStyle: AppTypography.buttonSmall,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.smMd,
          vertical: AppSpacing.xs,
        ),
        minimumSize: Size(0, height),
        shape: const RoundedRectangleBorder(
          borderRadius: AppBorders.borderRadiusMd,
        ),
        elevation: 0,
      );
}
