import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../../core/theme/app_borders.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/app_toast.dart';
import '../../../../../core/widgets/show_delete_confirm.dart';
import '../../cubit/timetable/timetable_cubit.dart';
import '../../helpers/timetable_helpers.dart';
import 'group_switcher_widget.dart';
import 'timetable_add_form.dart';
import 'timetable_day_section.dart';
import 'timetable_edit_modal.dart';

class TimetableTab extends StatelessWidget {
  const TimetableTab({super.key});

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
        value: context.read<TimetableCubit>(),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(modalContext).viewInsets.bottom,
          ),
          child: const SingleChildScrollView(child: TimetableAddForm()),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TimetableCubit, TimetableState>(
      listenWhen: (prev, curr) =>
          curr.editingEntry != null && prev.editingEntry != curr.editingEntry,
      listener: (context, state) {
        if (state.editingEntry != null) {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppBorders.radiusLg),
              ),
            ),
            builder: (_) => BlocProvider.value(
              value: context.read<TimetableCubit>(),
              child: TimetableEditModal(entry: state.editingEntry!),
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<TimetableCubit>();
        final currentGroup = state.groups.isNotEmpty
            ? state.groups[state.selectedGroupIndex]
            : null;
        final entries = currentGroup?.entries ?? [];
        final groupedByDay = groupEntriesByDay(entries);
        // Sort day keys by the canonical day order
        final sortedDays = groupedByDay.keys.toList()
          ..sort((a, b) => dayOrder.indexOf(a).compareTo(dayOrder.indexOf(b)));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const GroupSwitcherWidget(),
            const SizedBox(height: AppSpacing.md),
            if (currentGroup != null)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          currentGroup.name,
                          style: AppTypography.h4.copyWith(
                            color: AppColors.foreground,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Quản lý lịch học hàng tuần của bạn',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.smMd),
                  ElevatedButton(
                    onPressed: () => _showAddModal(context),
                    child: const Icon(LucideIcons.plus, size: 16),
                  ),
                ],
              ),
            const SizedBox(height: AppSpacing.smMd),
            // Content
            Expanded(
              child: entries.isEmpty
                  ? _EmptyState()
                  : ListView.builder(
                      itemCount: sortedDays.length,
                      itemBuilder: (context, index) {
                        final day = sortedDays[index];
                        return TimetableDaySection(
                          day: day,
                          entries: groupedByDay[day]!,
                          onEdit: (entry) => cubit.setEditingEntry(entry),
                          onDelete: (entryId) async {
                            final confirmed = await showDeleteConfirm(
                              context,
                              title: 'Xóa môn học',
                              message: 'Bạn có chắc chắn muốn xóa môn học này?',
                            );
                            if (confirmed == true && context.mounted) {
                              cubit.deleteEntry(entryId);
                              AppToast.success(context, 'Đã xóa môn học');
                            }
                          },
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
            LucideIcons.calendar,
            size: 48,
            color: AppColors.mutedForeground,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Chưa có lịch học nào',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Nhấn Thêm lịch học để bắt đầu',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.mutedForeground,
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
        shape: RoundedRectangleBorder(borderRadius: AppBorders.borderRadiusSm),
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
