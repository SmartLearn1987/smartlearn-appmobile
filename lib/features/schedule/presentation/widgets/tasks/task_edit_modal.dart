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

class TaskEditModal extends StatefulWidget {
  const TaskEditModal({required this.task, super.key});

  final TaskItemEntity task;

  @override
  State<TaskEditModal> createState() => _TaskEditModalState();
}

class _TaskEditModalState extends State<TaskEditModal> {
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

    final updated = TaskItemEntity(
      id: widget.task.id,
      title: title,
      description: _descriptionController.text.trim(),
      dueDate: _dueDate,
      completed: widget.task.completed,
      priority: _priority,
      createdAt: widget.task.createdAt,
    );

    context.read<TasksCubit>().editTask(updated);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã cập nhật nhiệm vụ'),
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
    );
  }
}
