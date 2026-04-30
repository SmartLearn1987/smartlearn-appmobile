import 'package:flutter/material.dart';

import '../theme/app_borders.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Shows a confirmation dialog before a destructive delete action.
///
/// Returns `true` if the user confirmed, `false` or `null` otherwise.
///
/// Example:
/// ```dart
/// onDelete: () async {
///   final confirmed = await showDeleteConfirm(context, title: 'Xóa ghi chú');
///   if (confirmed == true && context.mounted) {
///     cubit.deleteNote(note.id);
///   }
/// }
/// ```
Future<bool?> showDeleteConfirm(
  BuildContext context, {
  required String title,
  String? message,
}) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: AppBorders.borderRadiusLg,
      ),
      title: Text(
        title,
        style: AppTypography.labelLarge.copyWith(color: AppColors.foreground),
      ),
      content: Text(
        message ?? 'Bạn có chắc chắn muốn xóa? Hành động này không thể hoàn tác.',
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.mutedForeground,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(
            'Hủy',
            style: AppTypography.buttonMedium.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.destructive,
          ),
          child: Text(
            'Xóa',
            style: AppTypography.buttonMedium.copyWith(
              color: AppColors.destructive,
            ),
          ),
        ),
      ],
    ),
  );
}
