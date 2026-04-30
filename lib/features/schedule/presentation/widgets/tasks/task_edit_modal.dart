import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_borders.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/app_dropdown_field.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../../core/widgets/app_toast.dart';
import '../../../domain/entities/task_item_entity.dart';
import '../../cubit/tasks/tasks_cubit.dart';
import 'task_add_form.dart';

const _priorityItems = <DropdownMenuItem<String>>[
  DropdownMenuItem(value: 'high', child: Text('Cao')),
  DropdownMenuItem(value: 'medium', child: Text('Trung bình')),
  DropdownMenuItem(value: 'low', child: Text('Thấp')),
];

class TaskEditModal extends StatefulWidget {
  const TaskEditModal({required this.task, super.key});

  final TaskItemEntity task;

  @override
  State<TaskEditModal> createState() => _TaskEditModalState();
}

class _TaskEditModalState extends State<TaskEditModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime? _dueDate;
  late String _priority;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController =
        TextEditingController(text: widget.task.description);
    _dueDate = widget.task.dueDate;
    _priority = widget.task.priority;
  }

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
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final updated = TaskItemEntity(
      id: widget.task.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      dueDate: _dueDate,
      completed: widget.task.completed,
      priority: _priority,
      createdAt: widget.task.createdAt,
    );

    context.read<TasksCubit>().editTask(updated);
    Navigator.of(context).pop();
    AppToast.success(context, 'Đã cập nhật nhiệm vụ');
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
                'Sửa nhiệm vụ',
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
                      onPressed: () {
                        context.read<TasksCubit>().setEditingTask(null);
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
