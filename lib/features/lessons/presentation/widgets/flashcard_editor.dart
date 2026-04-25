import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import 'csv_import_dialog.dart';

/// Data class representing a single flashcard in the editor.
class EditableFlashcard {
  EditableFlashcard({
    TextEditingController? frontController,
    TextEditingController? backController,
  })  : frontController = frontController ?? TextEditingController(),
        backController = backController ?? TextEditingController();

  final TextEditingController frontController;
  final TextEditingController backController;

  void dispose() {
    frontController.dispose();
    backController.dispose();
  }
}

/// Editor widget for managing a list of flashcards.
///
/// Displays each flashcard with front (term) and back (definition) text fields,
/// plus a delete button. Supports adding individual cards and importing from CSV.
///
/// The parent can access the current flashcard data via
/// [FlashcardEditorState.flashcards].
class FlashcardEditor extends StatefulWidget {
  const FlashcardEditor({
    super.key,
    this.initialFlashcards = const [],
    this.onChanged,
  });

  /// Initial flashcard data for edit mode.
  /// Each map should contain: `front` (String), `back` (String).
  final List<Map<String, String>> initialFlashcards;

  /// Called whenever the flashcard list changes.
  final VoidCallback? onChanged;

  @override
  State<FlashcardEditor> createState() => FlashcardEditorState();
}

class FlashcardEditorState extends State<FlashcardEditor> {
  final List<EditableFlashcard> _flashcards = [];

  @override
  void initState() {
    super.initState();
    for (final fc in widget.initialFlashcards) {
      _flashcards.add(
        EditableFlashcard(
          frontController: TextEditingController(text: fc['front'] ?? ''),
          backController: TextEditingController(text: fc['back'] ?? ''),
        ),
      );
    }
  }

  @override
  void dispose() {
    for (final fc in _flashcards) {
      fc.dispose();
    }
    super.dispose();
  }

  /// Returns the current list of flashcard data as maps.
  List<Map<String, String>> get flashcards => _flashcards
      .map(
        (fc) => <String, String>{
          'front': fc.frontController.text,
          'back': fc.backController.text,
        },
      )
      .toList();

  void _addFlashcard() {
    setState(() {
      _flashcards.add(EditableFlashcard());
    });
    widget.onChanged?.call();
  }

  void _removeFlashcard(int index) {
    setState(() {
      _flashcards[index].dispose();
      _flashcards.removeAt(index);
    });
    widget.onChanged?.call();
  }

  Future<void> _importCsv() async {
    final parsed = await CsvImportDialog.show(context);
    if (parsed == null || parsed.isEmpty) return;

    setState(() {
      for (final entry in parsed) {
        _flashcards.add(
          EditableFlashcard(
            frontController: TextEditingController(text: entry['front'] ?? ''),
            backController: TextEditingController(text: entry['back'] ?? ''),
          ),
        );
      }
    });
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_flashcards.isEmpty)
          _buildEmptyState()
        else
          ..._flashcards.asMap().entries.map(
                (entry) => _buildFlashcardCard(entry.key, entry.value),
              ),
        const SizedBox(height: AppSpacing.smMd),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.mdLg),
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: AppBorders.borderRadiusSm,
        border: Border.all(
          color: AppColors.border,
          width: AppBorders.widthThin,
        ),
      ),
      child: Column(
        children: [
          Icon(
            LucideIcons.layers,
            size: 32,
            color: AppColors.mutedForeground,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Chưa có thẻ nào. Nhấn "Thêm thẻ" hoặc "Nhập" để bắt đầu.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.mutedForeground,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcardCard(int index, EditableFlashcard flashcard) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppBorders.borderRadiusSm,
          border: Border.all(
            color: AppColors.border,
            width: AppBorders.widthThin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader(index),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.smMd,
                0,
                AppSpacing.smMd,
                AppSpacing.smMd,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    controller: flashcard.frontController,
                    hintText: 'Mặt trước (thuật ngữ)',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildTextField(
                    controller: flashcard.backController,
                    hintText: 'Mặt sau (định nghĩa)',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(int index) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.smMd,
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.accentLight,
              borderRadius: AppBorders.borderRadiusSm,
            ),
            child: Text(
              'Thẻ ${index + 1}',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.accent,
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 32,
            height: 32,
            child: IconButton(
              onPressed: () => _removeFlashcard(index),
              icon: const Icon(LucideIcons.trash2, size: 16),
              color: AppColors.destructive,
              padding: EdgeInsets.zero,
              splashRadius: 16,
              tooltip: 'Xóa thẻ',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      onChanged: (_) => widget.onChanged?.call(),
      style: AppTypography.bodyMedium.copyWith(color: AppColors.foreground),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.mutedForeground,
        ),
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.smMd,
        ),
        isDense: true,
        border: _inputBorder(AppColors.input),
        enabledBorder: _inputBorder(AppColors.input),
        focusedBorder:
            _inputBorder(AppColors.primary, width: AppBorders.widthMedium),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _addFlashcard,
            icon: const Icon(LucideIcons.plus, size: 16),
            label: const Text('Thêm thẻ'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accent,
              textStyle: AppTypography.buttonMedium,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.smMd),
              shape: RoundedRectangleBorder(
                borderRadius: AppBorders.borderRadiusSm,
              ),
              side: BorderSide(
                color: AppColors.accent.withValues(alpha: 0.3),
                width: AppBorders.widthThin,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _importCsv,
            icon: const Icon(LucideIcons.fileInput, size: 16),
            label: const Text('Nhập'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accent,
              textStyle: AppTypography.buttonMedium,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.smMd),
              shape: RoundedRectangleBorder(
                borderRadius: AppBorders.borderRadiusSm,
              ),
              side: BorderSide(
                color: AppColors.accent.withValues(alpha: 0.3),
                width: AppBorders.widthThin,
              ),
            ),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _inputBorder(Color color,
      {double width = AppBorders.widthThin}) {
    return OutlineInputBorder(
      borderRadius: AppBorders.borderRadiusSm,
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
