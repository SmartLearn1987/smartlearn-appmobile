import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_borders.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/note_item_entity.dart';
import '../../cubit/notes/notes_cubit.dart';
import '../shared/color_picker_widget.dart';
import 'note_item_card.dart';

class NoteAddForm extends StatefulWidget {
  const NoteAddForm({super.key});

  @override
  State<NoteAddForm> createState() => _NoteAddFormState();
}

class _NoteAddFormState extends State<NoteAddForm> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  int _selectedColor = 0;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tiêu đề hoặc nội dung'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final note = NoteItemEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      color: _selectedColor,
      updatedAt: DateTime.now(),
    );

    context.read<NotesCubit>().addNote(note);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã thêm ghi chú'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppBorders.borderRadiusLg,
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ghi chú mới',
              style: AppTypography.h4.copyWith(color: AppColors.foreground),
            ),
            const SizedBox(height: AppSpacing.md),
            // Color picker
            Text(
              'Màu sắc',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ColorPickerWidget(
              colors: noteColorsLight,
              selectedIndex: _selectedColor,
              onChanged: (index) => setState(() => _selectedColor = index),
            ),
            const SizedBox(height: AppSpacing.smMd),
            // Title input
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Tiêu đề ghi chú',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: AppSpacing.smMd),
            // Content input
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Nội dung ghi chú...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        context.read<NotesCubit>().toggleAddForm(),
                    style: OutlinedButton.styleFrom(
                      shape: AppBorders.shapeSm,
                    ),
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.primaryForeground,
                      shape: AppBorders.shapeSm,
                    ),
                    child: const Text('Lưu'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
