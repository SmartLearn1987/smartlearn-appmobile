import 'package:flutter/material.dart';

import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_colors.dart';

/// Reusable dialog for confirming curriculum deletion.
///
/// Shows a warning message and provides cancel/confirm actions.
/// The caller is responsible for dispatching the delete event
/// via the [onConfirm] callback.
class DeleteConfirmationDialog extends StatelessWidget {
  const DeleteConfirmationDialog({required this.onConfirm, super.key});

  /// Called when the user taps the confirm ("Xóa") button.
  final VoidCallback onConfirm;

  /// Convenience helper to show the dialog via [showDialog].
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onConfirm,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => DeleteConfirmationDialog(onConfirm: onConfirm),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: AppBorders.borderRadiusLg,
      ),
      title: const Text('Xóa giáo trình'),
      content: const Text(
        'Xóa giáo trình này? Toàn bộ bài học trong giáo trình sẽ bị xóa.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          style: TextButton.styleFrom(foregroundColor: AppColors.destructive),
          child: const Text('Xóa'),
        ),
      ],
    );
  }
}
