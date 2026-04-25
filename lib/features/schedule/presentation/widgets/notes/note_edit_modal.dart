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

class NoteEditModal extends StatefulWidget {
  const NoteEditModal({required this.note, super.key});

  final NoteItemEntity note;

  @override
  State<NoteEditModal> createState() => _NoteEditModalState();
}

class _NoteEditModalState extends State<NoteEditModal> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late int _selectedColor;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _selectedColor = widget.note.color;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _save() {
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

    final updated = NoteItemEntity(
      id: widget.note.id,
      title: title,
      content: content,
      color: _selectedColor,
      updatedAt: DateTime.now(),
    );

    context.read<NotesCubit>().editNote(updated);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã lưu ghi chú'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.mutedForeground,
                  borderRadius: AppBorders.borderRadiusFull,
                ),
                child: const SizedBox(width: 40, height: 4),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Sửa ghi chú',
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
                    onPressed: () {
                      context.read<NotesCubit>().setEditingNote(null);
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      shape: AppBorders.shapeSm,
                    ),
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.primaryForeground,
                      shape: AppBorders.shapeSm,
                    ),
                    child: const Text('Lưu thay đổi'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}
