import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../../core/theme/app_borders.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/task_item_entity.dart';
import '../../cubit/tasks/tasks_cubit.dart';

const _priorityConfig = <String, ({String label, Color color})>{
  'high': (label: 'Cao', color: Color(0xFFEF4444)),
  'medium': (label: 'Trung bình', color: Color(0xFFEAB308)),
  'low': (label: 'Thấp', color: Color(0xFF10B981)),
};

class TaskDetailModal extends StatelessWidget {
  const TaskDetailModal({required this.task, super.key});

  final TaskItemEntity task;

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final priority =
        _priorityConfig[task.priority] ?? _priorityConfig['medium']!;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      shape: RoundedRectangleBorder(borderRadius: AppBorders.borderRadiusLg),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: title + close button
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: AppTypography.h4.copyWith(
                      color: AppColors.foreground,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(
                    LucideIcons.x,
                    size: 18,
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // Priority + Status badges
            Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: priority.color.withValues(alpha: 0.15),
                    borderRadius: AppBorders.borderRadiusFull,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    child: Text(
                      priority.label,
                      style: AppTypography.caption.copyWith(
                        color: priority.color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: task.completed
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : const Color(0xFF3B82F6).withValues(alpha: 0.15),
                    borderRadius: AppBorders.borderRadiusFull,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    child: Text(
                      task.completed ? 'Hoàn thành' : 'Đang làm',
                      style: AppTypography.caption.copyWith(
                        color: task.completed
                            ? AppColors.primary
                            : const Color(0xFF3B82F6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Description
            if (task.description?.isNotEmpty ?? false) ...[
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.muted,
                  borderRadius: AppBorders.borderRadiusLg,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: AppSpacing.paddingSm,
                    child: Text(
                      task.description!,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.foreground,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            // Due date
            Row(
              children: [
                Icon(
                  LucideIcons.calendar,
                  size: 14,
                  color: AppColors.mutedForeground,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Hạn chót: ',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
                Text(
                  task.dueDate != null
                      ? _formatDate(task.dueDate!)
                      : 'Không có',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.foreground,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // Created date
            Row(
              children: [
                Icon(
                  LucideIcons.clock,
                  size: 14,
                  color: AppColors.mutedForeground,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Ngày tạo: ',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
                Text(
                  _formatDate(task.createdAt),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.foreground,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: task.completed
                      ? OutlinedButton(
                          onPressed: () {
                            context.read<TasksCubit>().toggleCompletion(task.id);
                            Navigator.of(context).pop();
                          },
                          style: OutlinedButton.styleFrom(
                            shape: AppBorders.shapeSm,
                          ),
                          child: const Text('Đánh dấu chưa xong'),
                        )
                      : ElevatedButton(
                          onPressed: () {
                            context.read<TasksCubit>().toggleCompletion(task.id);
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.primaryForeground,
                            shape: AppBorders.shapeSm,
                          ),
                          child: const Text('Hoàn thành ngay'),
                        ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.read<TasksCubit>().setViewingTask(null);
                      context.read<TasksCubit>().setEditingTask(task);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      shape: AppBorders.shapeSm,
                    ),
                    child: const Text('Sửa'),
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
