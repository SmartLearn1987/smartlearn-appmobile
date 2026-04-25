import 'package:flutter/material.dart';

import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../helpers/csv_flashcard_parser.dart';

/// Dialog for importing flashcards from CSV text.
///
/// Each line should contain a term and definition separated by a comma.
/// Example:
/// ```
/// apple,táo
/// book,sách
/// ```
///
/// Returns a list of `{front, back}` maps via [Navigator.pop] on submit,
/// or `null` if cancelled.
class CsvImportDialog extends StatefulWidget {
  const CsvImportDialog({super.key});

  /// Shows the dialog and returns parsed flashcard data, or `null` if
  /// the user cancels.
  static Future<List<Map<String, String>>?> show(BuildContext context) {
    return showDialog<List<Map<String, String>>>(
      context: context,
      builder: (_) => const CsvImportDialog(),
    );
  }

  @override
  State<CsvImportDialog> createState() => _CsvImportDialogState();
}

class _CsvImportDialogState extends State<CsvImportDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSubmit() {
    final parsed = parseCsvFlashcards(_controller.text);
    Navigator.of(context).pop(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: AppBorders.borderRadiusMd),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.mdLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nhập flashcards từ CSV',
              style: AppTypography.h4.copyWith(color: AppColors.foreground),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Mỗi dòng gồm thuật ngữ và định nghĩa, cách nhau bởi dấu phẩy.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _controller,
              maxLines: 8,
              minLines: 5,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.foreground,
              ),
              decoration: InputDecoration(
                hintText: 'VD:\napple,táo\nbook,sách',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.mutedForeground,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.all(AppSpacing.smMd),
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
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.mutedForeground,
                    textStyle: AppTypography.buttonMedium,
                  ),
                  child: const Text('Hủy'),
                ),
                const SizedBox(width: AppSpacing.sm),
                ElevatedButton(
                  onPressed: _onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.primaryForeground,
                    textStyle: AppTypography.buttonMedium,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppBorders.borderRadiusSm,
                    ),
                  ),
                  child: const Text('Nhập'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
