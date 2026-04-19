import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_borders.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/task_item_entity.dart';
import '../../cubit/tasks/tasks_cubit.dart';

const _priorities = <String, String>{
  'high': 'Cao',
  'medium': 'Trung bình',
  'low': 'Thấp',
};

class TaskAddForm extends StatefulWidget {
  const TaskAddForm({super.key});

  @override
  State<TaskAddForm> createState() => _TaskAddFormState();
}

class _TaskAddFormState extends State<TaskAddForm> {
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
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tiêu đề nhiệm vụ'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final task = TaskItemEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: _descriptionController.text.trim(),
      dueDate: _dueDate,
      completed: false,
      priority: _priority,
      createdAt: DateTime.now(),
    );

    context.read<TasksCubit>().addTask(task);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã thêm nhiệm vụ'),
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
              'Nhiệm vụ mới',
              style: AppTypography.h4.copyWith(color: AppColors.foreground),
            ),
            const SizedBox(height: AppSpacing.md),
            // Title
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Tiêu đề nhiệm vụ *',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: AppSpacing.smMd),
            // Description
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Mô tả chi tiết',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: AppSpacing.smMd),
            // Due date picker
            GestureDetector(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Hạn chót',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                child: Text(
                  _dueDate != null ? _formatDate(_dueDate!) : 'Chọn ngày',
                  style: AppTypography.bodyMedium.copyWith(
                    color: _dueDate != null
                        ? AppColors.foreground
                        : AppColors.mutedForeground,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.smMd),
            // Priority dropdown
            DropdownMenu<String>(
              initialSelection: _priority,
              label: const Text('Độ ưu tiên'),
              expandedInsets: EdgeInsets.zero,
              dropdownMenuEntries: _priorities.entries
                  .map(
                    (e) => DropdownMenuEntry(
                      value: e.key,
                      label: e.value,
                    ),
                  )
                  .toList(),
              onSelected: (value) {
                if (value != null) setState(() => _priority = value);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            // Action buttons
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
                    child: const Text('Thêm'),
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
