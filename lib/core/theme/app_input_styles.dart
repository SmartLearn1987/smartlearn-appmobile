import 'package:flutter/material.dart';
import 'app_borders.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Smart Learn Input Decoration Tokens
abstract final class AppInputStyles {
  static InputDecorationTheme get theme => InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.smMd,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.mutedForeground,
        ),
        labelStyle: AppTypography.labelMedium.copyWith(
          color: AppColors.foreground,
        ),
        border: OutlineInputBorder(
          borderRadius: AppBorders.borderRadiusSm,
          borderSide: const BorderSide(
            color: AppColors.input,
            width: AppBorders.widthThin,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppBorders.borderRadiusSm,
          borderSide: const BorderSide(
            color: AppColors.input,
            width: AppBorders.widthThin,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorders.borderRadiusSm,
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: AppBorders.widthMedium,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppBorders.borderRadiusSm,
          borderSide: const BorderSide(
            color: AppColors.destructive,
            width: AppBorders.widthThin,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppBorders.borderRadiusSm,
          borderSide: const BorderSide(
            color: AppColors.destructive,
            width: AppBorders.widthMedium,
          ),
        ),
      );
}
