import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_borders.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../../core/widgets/app_toast.dart';
import '../../cubit/notes/notes_cubit.dart';

class NoteAddForm extends StatefulWidget {
  const NoteAddForm({super.key});

  @override
  State<NoteAddForm> createState() => _NoteAddFormState();
}

class _NoteAddFormState extends State<NoteAddForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<NotesCubit>().addNote(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
        );
    Navigator.of(context).pop();
    AppToast.success(context, 'Đã thêm ghi chú');
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ghi chú mới',
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
                      onPressed: () => Navigator.of(context).pop(),
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
      ),
    );
  }
}
