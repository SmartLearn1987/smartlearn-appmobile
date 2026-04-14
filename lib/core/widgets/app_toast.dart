import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Centralized toast/snackbar utility.
///
/// Usage:
/// ```dart
/// AppToast.success(context, 'Thành công!');
/// AppToast.error(context, 'Có lỗi xảy ra');
/// AppToast.info(context, 'Sắp ra mắt');
/// ```
abstract final class AppToast {
  /// Shows a success toast (green).
  static void success(BuildContext context, String message) =>
      _show(context, message, AppColors.success, AppColors.successForeground);

  /// Shows an error toast (red).
  static void error(BuildContext context, String message) =>
      _show(
        context,
        message,
        AppColors.destructive,
        AppColors.destructiveForeground,
      );

  /// Shows an info toast (default style).
  static void info(BuildContext context, String message) =>
      _show(context, message);

  static void _show(
    BuildContext context,
    String message, [
    Color? backgroundColor,
    Color? foregroundColor,
  ]) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: foregroundColor != null
                ? AppTypography.bodyMedium.copyWith(color: foregroundColor)
                : null,
          ),
          backgroundColor: backgroundColor,
        ),
      );
  }
}
