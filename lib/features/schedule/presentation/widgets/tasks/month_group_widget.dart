import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../../core/theme/app_borders.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/task_item_entity.dart';
import '../../helpers/task_helpers.dart';

class MonthGroupWidget extends StatelessWidget {
  const MonthGroupWidget({
    required this.monthKey,
    required this.tasks,
    required this.isCollapsed,
    required this.onToggle,
    required this.childBuilder,
    super.key,
  });

  final String monthKey;
  final List<TaskItemEntity> tasks;
  final bool isCollapsed;
  final VoidCallback onToggle;
  final Widget Function(TaskItemEntity task) childBuilder;

  @override
  Widget build(BuildContext context) {
    final completedCount = tasks.where((t) => t.completed).length;
    final total = tasks.length;
    final progress = computeMonthProgress(tasks);
    final percent = (progress * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        GestureDetector(
          onTap: onToggle,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: AppBorders.borderRadiusSm,
              border: Border.all(color: AppColors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.smMd,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          monthKey,
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.foreground,
                          ),
                        ),
                      ),
                      // Count badge
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: AppBorders.borderRadiusFull,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xxs,
                          ),
                          child: Text(
                            '$total',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Icon(
                        isCollapsed
                            ? LucideIcons.chevronDown
                            : LucideIcons.chevronUp,
                        size: 18,
                        color: AppColors.mutedForeground,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Progress bar
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: AppBorders.borderRadiusFull,
                          child: SizedBox(
                            height: 6,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: AppColors.muted,
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: FractionallySizedBox(
                                  widthFactor: progress,
                                  child: const DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF2D9B63),
                                          Color(0xFF10B981),
                                        ],
                                      ),
                                    ),
                                    child: SizedBox.expand(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '$completedCount/$total hoàn thành ($percent%)',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.mutedForeground,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        // Task cards
        if (!isCollapsed) ...[
          const SizedBox(height: AppSpacing.sm),
          ...tasks.map(
            (task) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: childBuilder(task),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}
