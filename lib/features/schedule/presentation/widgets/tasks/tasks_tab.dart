import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../../core/theme/app_borders.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../cubit/tasks/tasks_cubit.dart';
import '../../helpers/task_helpers.dart';
import 'month_group_widget.dart';
import 'task_add_form.dart';
import 'task_detail_modal.dart';
import 'task_edit_modal.dart';
import 'task_filter_tabs.dart';
import 'task_item_card.dart';

class TasksTab extends StatelessWidget {
  const TasksTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TasksCubit, TasksState>(
      listenWhen: (prev, curr) =>
          (curr.editingTask != null &&
              prev.editingTask != curr.editingTask) ||
          (curr.viewingTask != null &&
              prev.viewingTask != curr.viewingTask),
      listener: (context, state) {
        if (state.viewingTask != null) {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppBorders.radiusLg),
              ),
            ),
            builder: (_) => BlocProvider.value(
              value: context.read<TasksCubit>(),
              child: TaskDetailModal(task: state.viewingTask!),
            ),
          ).whenComplete(() {
            if (context.mounted) {
              context.read<TasksCubit>().setViewingTask(null);
            }
          });
        } else if (state.editingTask != null) {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppBorders.radiusLg),
              ),
            ),
            builder: (_) => BlocProvider.value(
              value: context.read<TasksCubit>(),
              child: TaskEditModal(task: state.editingTask!),
            ),
          ).whenComplete(() {
            if (context.mounted) {
              context.read<TasksCubit>().setEditingTask(null);
            }
          });
        }
      },
      builder: (context, state) {
        final cubit = context.read<TasksCubit>();
        final filtered = filterTasks(state.tasks, state.filter);
        final sorted = sortTasksByDueDate(filtered);
        final grouped = groupTasksByMonth(sorted);
        // Sort month keys: "Không có hạn chót" goes last
        final monthKeys = grouped.keys.toList()
          ..sort((a, b) {
            if (a == 'Không có hạn chót') return 1;
            if (b == 'Không có hạn chót') return -1;
            return a.compareTo(b);
          });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + Add button
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Nhiệm vụ',
                    style: AppTypography.h4.copyWith(
                      color: AppColors.foreground,
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: cubit.toggleAddForm,
                  icon: Icon(
                    state.isAddingTask ? LucideIcons.x : LucideIcons.plus,
                    size: 16,
                  ),
                  label: Text(
                    state.isAddingTask ? 'Đóng' : 'Thêm nhiệm vụ',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: AppBorders.shapeSm,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.smMd),
            // Filter tabs
            TaskFilterTabs(
              selectedFilter: state.filter,
              onFilterChanged: cubit.changeFilter,
            ),
            const SizedBox(height: AppSpacing.smMd),
            // Add form
            if (state.isAddingTask) ...[
              const TaskAddForm(),
              const SizedBox(height: AppSpacing.md),
            ],
            // Content
            Expanded(
              child: sorted.isEmpty
                  ? _EmptyState()
                  : ListView.builder(
                      itemCount: monthKeys.length,
                      itemBuilder: (context, index) {
                        final monthKey = monthKeys[index];
                        final tasks = grouped[monthKey]!;
                        final isCollapsed =
                            state.collapsedMonths.contains(monthKey);

                        return MonthGroupWidget(
                          monthKey: monthKey,
                          tasks: tasks,
                          isCollapsed: isCollapsed,
                          onToggle: () =>
                              cubit.toggleMonthCollapse(monthKey),
                          childBuilder: (task) => TaskItemCard(
                            task: task,
                            onToggle: () =>
                                cubit.toggleCompletion(task.id),
                            onView: () => cubit.setViewingTask(task),
                            onEdit: () => cubit.setEditingTask(task),
                            onDelete: () {
                              cubit.deleteTask(task.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đã xóa nhiệm vụ'),
                                  duration: Duration(seconds: 3),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.checkSquare,
            size: 48,
            color: AppColors.mutedForeground,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Không có nhiệm vụ nào',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.foreground,
            ),
          ),
        ],
      ),
    );
  }
}
