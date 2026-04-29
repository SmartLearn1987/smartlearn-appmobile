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

  void _showAddModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppBorders.radiusLg),
        ),
      ),
      builder: (modalContext) => BlocProvider.value(
        value: context.read<TasksCubit>(),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(modalContext).viewInsets.bottom,
          ),
          child: const SingleChildScrollView(
            child: TaskAddForm(),
          ),
        ),
      ),
    );
  }

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
          showDialog<void>(
            context: context,
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
            // Title + Add + Refresh buttons
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
                  onPressed: () => _showAddModal(context),
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: const Text('Thêm nhiệm vụ'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: AppBorders.shapeSm,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _RefreshButton(
                  isLoading: state.status == TasksStatus.loading,
                  onPressed: () => cubit.loadTasks(),
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

class _RefreshButton extends StatefulWidget {
  const _RefreshButton({required this.isLoading, required this.onPressed});

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  State<_RefreshButton> createState() => _RefreshButtonState();
}

class _RefreshButtonState extends State<_RefreshButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void didUpdateWidget(_RefreshButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading) {
      _controller.repeat();
    } else {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.isLoading ? null : widget.onPressed,
      tooltip: 'Làm mới',
      style: IconButton.styleFrom(
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: AppBorders.borderRadiusSm,
        ),
      ),
      icon: RotationTransition(
        turns: _controller,
        child: Icon(
          LucideIcons.refreshCw,
          size: 16,
          color: widget.isLoading
              ? AppColors.mutedForeground
              : AppColors.foreground,
        ),
      ),
    );
  }
}
