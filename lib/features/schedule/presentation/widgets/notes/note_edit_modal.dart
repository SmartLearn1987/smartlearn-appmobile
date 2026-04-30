import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_borders.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../../core/widgets/app_toast.dart';
import '../../../domain/entities/note_item_entity.dart';
import '../../cubit/notes/notes_cubit.dart';

class NoteEditModal extends StatefulWidget {
  const NoteEditModal({required this.note, super.key});

  final NoteItemEntity note;

  @override
  State<NoteEditModal> createState() => _NoteEditModalState();
}

class _NoteEditModalState extends State<NoteEditModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// At least one of title or content must be non-empty.
  String? _validateContent(String? value) {
    if (_titleController.text.trim().isEmpty &&
        (value == null || value.trim().isEmpty)) {
      return 'Vui lòng nhập tiêu đề hoặc nội dung';
    }
    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final updated = NoteItemEntity(
      id: widget.note.id,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      updatedAt: DateTime.now(),
    );

    context.read<NotesCubit>().editNote(updated);
    Navigator.of(context).pop();
    AppToast.success(context, 'Đã lưu ghi chú');
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
        child: Form(
          key: _formKey,
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
              const SizedBox(height: AppSpacing.smMd),
              // Title (optional, but at least one field required)
              AppTextField(
                controller: _titleController,
                label: 'Tiêu đề',
                hintText: 'Tiêu đề ghi chú',
                textInputAction: TextInputAction.next,
                // Revalidate content when title changes so the error clears
                onChanged: (_) => _formKey.currentState?.validate(),
              ),
              const SizedBox(height: AppSpacing.smMd),
              // Content
              AppTextField(
                controller: _contentController,
                label: 'Nội dung',
                hintText: 'Nội dung ghi chú...',
                maxLines: 5,
                validator: _validateContent,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                textInputAction: TextInputAction.newline,
              ),
              const SizedBox(height: AppSpacing.md),
              // Buttons
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
      ),
    );
  }
}
