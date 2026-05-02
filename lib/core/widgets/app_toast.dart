import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

/// Centralized toast utility backed by the `toastification` package.
///
/// Usage:
/// ```dart
/// AppToast.success(context, 'Thành công!');
/// AppToast.error(context, 'Có lỗi xảy ra');
/// AppToast.info(context, 'Sắp ra mắt');
/// AppToast.warning(context, 'Cảnh báo');
/// ```
///
/// Context is optional when [ToastificationWrapper] wraps the root widget.
abstract final class AppToast {
  static const _duration = Duration(seconds: 4);
  static const _alignment = Alignment.topCenter;

  /// Shows a success toast (green).
  static void success(BuildContext context, String message) =>
      _show(context, message, ToastificationType.success);

  /// Shows an error toast (red).
  static void error(BuildContext context, String message) =>
      _show(context, message, ToastificationType.error);

  /// Shows an info toast (blue).
  static void info(BuildContext context, String message) =>
      _show(context, message, ToastificationType.info);

  /// Shows a warning toast (amber).
  static void warning(BuildContext context, String message) =>
      _show(context, message, ToastificationType.warning);

  static void _show(
    BuildContext context,
    String message,
    ToastificationType type,
  ) {
    toastification.show(
      context: context,
      type: type,
      style: ToastificationStyle.minimal,
      title: Text(
        message,
        softWrap: true,
        overflow: TextOverflow.visible,
        maxLines: 10,
      ),
      alignment: _alignment,
      autoCloseDuration: _duration,
      showProgressBar: false,
      animationDuration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: BorderRadius.circular(12),
    );
  }
}
