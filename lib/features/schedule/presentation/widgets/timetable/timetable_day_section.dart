import 'package:flutter/material.dart';

import '../../../../../core/theme/app_borders.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/timetable_entry_entity.dart';
import '../../helpers/timetable_helpers.dart';
import 'timetable_entry_card.dart';

/// Day header colors keyed by day number (2=Thứ 2 … 8=Chủ nhật).
const dayHeaderColors = <int, Color>{
  2: Color(0xFF3B82F6),
  3: Color(0xFF10B981),
  4: Color(0xFF8B5CF6),
  5: Color(0xFFF97316),
  6: Color(0xFFEC4899),
  7: Color(0xFF06B6D4),
  8: Color(0xFFF43F5E),
};

/// Day names keyed by day number.
const dayNames = <int, String>{
  2: 'Thứ 2',
  3: 'Thứ 3',
  4: 'Thứ 4',
  5: 'Thứ 5',
  6: 'Thứ 6',
  7: 'Thứ 7',
  8: 'Chủ nhật',
};

class TimetableDaySection extends StatelessWidget {
  const TimetableDaySection({
    required this.day,
    required this.entries,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final int day;
  final List<TimetableEntryEntity> entries;
  final void Function(TimetableEntryEntity entry) onEdit;
  final void Function(String entryId) onDelete;

  @override
  Widget build(BuildContext context) {
    final headerColor = dayHeaderColors[day] ?? AppColors.primary;
    final dayName = dayNames[day] ?? 'Ngày $day';
    final sorted = sortEntriesByTime(entries);
    final periods = splitByPeriod(sorted);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: headerColor.withValues(alpha: 0.15),
            borderRadius: AppBorders.borderRadiusSm,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.smMd,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: headerColor,
                    borderRadius: AppBorders.borderRadiusFull,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    child: Text(
                      dayName,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primaryForeground,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (periods.morning.isNotEmpty) ...[
          _PeriodColumn(
            label: 'Sáng',
            entries: periods.morning,
            onEdit: onEdit,
            onDelete: onDelete,
          ),
        ],
        if (periods.afternoon.isNotEmpty) ...[
          if (periods.morning.isNotEmpty)
            const SizedBox(height: AppSpacing.sm),
          _PeriodColumn(
            label: 'Chiều',
            entries: periods.afternoon,
            onEdit: onEdit,
            onDelete: onDelete,
          ),
        ],
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}

class _PeriodColumn extends StatelessWidget {
  const _PeriodColumn({
    required this.label,
    required this.entries,
    required this.onEdit,
    required this.onDelete,
  });

  final String label;
  final List<TimetableEntryEntity> entries;
  final void Function(TimetableEntryEntity entry) onEdit;
  final void Function(String entryId) onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs),
          child: Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        ...entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: TimetableEntryCard(
              entry: entry,
              onEdit: () => onEdit(entry),
              onDelete: () => onDelete(entry.id),
            ),
          ),
        ),
      ],
    );
  }
}
