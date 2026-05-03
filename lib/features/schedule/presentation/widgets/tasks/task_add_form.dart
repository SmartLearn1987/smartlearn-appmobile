import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_borders.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/app_dropdown_field.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../../core/widgets/app_toast.dart';
import '../../cubit/tasks/tasks_cubit.dart';

const _priorityItems = <DropdownMenuItem<String>>[
  DropdownMenuItem(value: 'high', child: Text('Cao')),
  DropdownMenuItem(value: 'medium', child: Text('Trung bình')),
  DropdownMenuItem(value: 'low', child: Text('Thấp')),
];

class TaskAddForm extends StatefulWidget {
  const TaskAddForm({super.key});

  @override
  State<TaskAddForm> createState() => _TaskAddFormState();
}

class _TaskAddFormState extends State<TaskAddForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _dueDate;
  String _priority = 'medium';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() => _dueDate = picked);
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date.toLocal());
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<TasksCubit>().addTask(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          dueDate: _dueDate,
          priority: _priority,
        );
    Navigator.of(context).pop();
    AppToast.success(context, 'Đã thêm nhiệm vụ');
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
                'Nhiệm vụ mới',
                style: AppTypography.h4.copyWith(color: AppColors.foreground),
              ),
              const SizedBox(height: AppSpacing.md),
              // Title (required)
              AppTextField(
                controller: _titleController,
                label: 'Tiêu đề',
                hintText: 'Tiêu đề nhiệm vụ',
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Vui lòng nhập tiêu đề nhiệm vụ'
                    : null,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.smMd),
              // Description (optional)
              AppTextField(
                controller: _descriptionController,
                label: 'Mô tả',
                hintText: 'Mô tả chi tiết (tùy chọn)',
                maxLines: 3,
                textInputAction: TextInputAction.newline,
              ),
              const SizedBox(height: AppSpacing.smMd),
              // Due date picker
              DueDateField(
                dueDate: _dueDate,
                formatDate: _formatDate,
                onTap: _pickDate,
              ),
              const SizedBox(height: AppSpacing.smMd),
              // Priority dropdown
              AppDropdownField<String>(
                label: 'Độ ưu tiên',
                value: _priority,
                items: _priorityItems,
                onChanged: (v) {
                  if (v != null) setState(() => _priority = v);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.destructive,
                        side: const BorderSide(color: AppColors.destructive),
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
                      child: const Text('Thêm'),
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

/// Shared due-date picker field used by both add and edit forms.
class DueDateField extends StatelessWidget {
  const DueDateField({
    required this.dueDate,
    required this.formatDate,
    required this.onTap,
    super.key,
  });

  final DateTime? dueDate;
  final String Function(DateTime) formatDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Hạn chót',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.foreground,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: AppBorders.borderRadiusSm,
              border: Border.all(color: AppColors.input),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.calendar,
                  size: 18,
                  color: AppColors.mutedForeground,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  dueDate != null ? formatDate(dueDate!) : 'Chọn ngày',
                  style: AppTypography.bodyMedium.copyWith(
                    color: dueDate != null
                        ? AppColors.foreground
                        : AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
