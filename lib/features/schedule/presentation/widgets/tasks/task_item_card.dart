import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../../core/theme/app_borders.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/task_item_entity.dart';

/// Day-of-week abbreviations (DateTime.weekday: 1=Mon … 7=Sun).
const _dayAbbreviations = <int, String>{
  1: 'T2',
  2: 'T3',
  3: 'T4',
  4: 'T5',
  5: 'T6',
  6: 'T7',
  7: 'CN',
};

/// Day colors keyed by DateTime.weekday.
const _dayColors = <int, Color>{
  1: Color(0xFF3B82F6),
  2: Color(0xFF10B981),
  3: Color(0xFF8B5CF6),
  4: Color(0xFFF97316),
  5: Color(0xFFEC4899),
  6: Color(0xFF06B6D4),
  7: Color(0xFFF43F5E),
};

const _priorityConfig = <String, ({String label, Color color})>{
  'high': (label: 'Cao', color: Color(0xFFEF4444)),
  'medium': (label: 'Trung bình', color: Color(0xFFEAB308)),
  'low': (label: 'Thấp', color: Color(0xFF10B981)),
};

class TaskItemCard extends StatelessWidget {
  const TaskItemCard({
    required this.task,
    required this.onToggle,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final TaskItemEntity task;
  final VoidCallback onToggle;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  bool get _isOverdue =>
      !task.completed &&
      task.dueDate != null &&
      task.dueDate!.isBefore(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final opacity = task.completed ? 0.5 : 1.0;

    return Opacity(
      opacity: opacity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppBorders.borderRadiusLg,
          border: Border.all(color: AppColors.border),
        ),
        child: Padding(
          padding: AppSpacing.paddingSm,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox
              GestureDetector(
                onTap: onToggle,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.xs,
                    right: AppSpacing.sm,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task.completed
                          ? AppColors.primary
                          : Colors.transparent,
                      border: Border.all(
                        color: task.completed
                            ? AppColors.primary
                            : AppColors.mutedForeground,
                        width: 2,
                      ),
                    ),
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: task.completed
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                ),
              ),
              // Date badge
              if (task.dueDate != null) ...[
                _DateBadge(dueDate: task.dueDate!, isOverdue: _isOverdue),
                const SizedBox(width: AppSpacing.sm),
              ],
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + priority
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.foreground,
                              decoration: task.completed
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        _PriorityBadge(priority: task.priority),
                      ],
                    ),
                    // Description
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        task.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    // Created date + actions
                    Row(
                      children: [
                        Icon(
                          LucideIcons.clock,
                          size: 12,
                          color: AppColors.mutedForeground,
                        ),
                        const SizedBox(width: AppSpacing.xxs),
                        Text(
                          _formatDate(task.createdAt),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.mutedForeground,
                            fontSize: 11,
                          ),
                        ),
                        const Spacer(),
                        _ActionButton(
                          icon: LucideIcons.eye,
                          onTap: onView,
                          color: AppColors.mutedForeground,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        _ActionButton(
                          icon: LucideIcons.pencil,
                          onTap: onEdit,
                          color: AppColors.mutedForeground,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        _ActionButton(
                          icon: LucideIcons.trash2,
                          onTap: onDelete,
                          color: AppColors.destructive,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }
}

class _DateBadge extends StatelessWidget {
  const _DateBadge({required this.dueDate, required this.isOverdue});

  final DateTime dueDate;
  final bool isOverdue;

  @override
  Widget build(BuildContext context) {
    final weekday = dueDate.weekday;
    final dayAbbr = _dayAbbreviations[weekday] ?? '';
    final dayColor = _dayColors[weekday] ?? AppColors.primary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppBorders.borderRadiusSm,
        border: Border.all(
          color: isOverdue ? const Color(0xFFEF4444) : AppColors.border,
          width: isOverdue ? 1.5 : 1,
        ),
      ),
      child: SizedBox(
        width: 40,
        child: Column(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: dayColor.withValues(alpha: 0.15),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppBorders.radiusSm),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                  child: Text(
                    dayAbbr,
                    textAlign: TextAlign.center,
                    style: AppTypography.caption.copyWith(
                      color: dayColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
              child: Text(
                '${dueDate.day}',
                textAlign: TextAlign.center,
                style: AppTypography.labelMedium.copyWith(
                  color: isOverdue
                      ? const Color(0xFFEF4444)
                      : AppColors.foreground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});

  final String priority;

  @override
  Widget build(BuildContext context) {
    final config = _priorityConfig[priority] ??
        _priorityConfig['medium']!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.15),
        borderRadius: AppBorders.borderRadiusFull,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        child: Text(
          config.label,
          style: AppTypography.caption.copyWith(
            color: config.color,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }
}
