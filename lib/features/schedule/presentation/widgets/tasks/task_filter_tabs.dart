import 'package:flutter/material.dart';

import '../../../../../core/theme/app_borders.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

const _filters = <String, ({String label, Color color})>{
  'all': (label: 'Tất cả', color: Color(0xFF2D9B63)),
  'inProgress': (label: 'Đang làm', color: Color(0xFF3B82F6)),
  'completed': (label: 'Hoàn thành', color: Color(0xFF8B5CF6)),
};

class TaskFilterTabs extends StatelessWidget {
  const TaskFilterTabs({
    required this.selectedFilter,
    required this.onFilterChanged,
    super.key,
  });

  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _filters.entries.map((entry) {
        final isSelected = entry.key == selectedFilter;
        final color = entry.value.color;

        return Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm),
          child: GestureDetector(
            onTap: () => onFilterChanged(entry.key),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: isSelected ? color : AppColors.card,
                borderRadius: AppBorders.borderRadiusFull,
                border: Border.all(
                  color: isSelected ? color : AppColors.border,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.smMd,
                  vertical: AppSpacing.sm,
                ),
                child: Text(
                  entry.value.label,
                  style: AppTypography.labelSmall.copyWith(
                    color: isSelected ? Colors.white : color,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
