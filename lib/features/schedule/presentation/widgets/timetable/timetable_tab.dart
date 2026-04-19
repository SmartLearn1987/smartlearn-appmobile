import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../../core/theme/app_borders.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
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
          child: const SingleChildScrollView(
            child: TimetableAddForm(),
          ),
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
        // Sort day keys so they appear in order 2..8
        final sortedDays = groupedByDay.keys.toList()..sort();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const GroupSwitcherWidget(),
            const SizedBox(height: AppSpacing.md),
            if (currentGroup != null) ...[
              Text(
                currentGroup.name,
                style: AppTypography.h4.copyWith(color: AppColors.foreground),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Quản lý lịch học hàng tuần của bạn',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.smMd),
            // Add button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showAddModal(context),
                icon: const Icon(LucideIcons.plus, size: 16),
                label: const Text('Thêm môn học'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: AppBorders.shapeSm,
                ),
              ),
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
                          onDelete: (entryId) {
                            cubit.deleteEntry(entryId);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã xóa môn học'),
                                duration: Duration(seconds: 3),
                              ),
                            );
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
            'Chưa có môn học nào',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Nhấn Thêm môn học để bắt đầu',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}
