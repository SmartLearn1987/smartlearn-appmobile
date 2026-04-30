import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_borders.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/task_item_entity.dart';

class _PriorityStyle {
  final String label;
  final Color bg;
  final Color text;
  final Color border;

  _PriorityStyle({
    required this.label,
    required this.bg,
    required this.text,
    required this.border,
  });
}

final Map<String, _PriorityStyle> _priorityConfig = {
  "high": _PriorityStyle(
    label: "Cao",
    bg: const Color(0xFFFEE2E2), // red-100
    text: const Color(0xFFB91C1C), // red-700
    border: const Color(0xFFFECACA), // red-200
  ),
  "medium": _PriorityStyle(
    label: "Trung bình",
    bg: const Color(0xFFFEF9C3), // yellow-100
    text: const Color(0xFFA16207), // yellow-700
    border: const Color(0xFFFEF08A), // yellow-200
  ),
  "low": _PriorityStyle(
    label: "Thấp",
    bg: const Color(0xFFDCFCE7), // green-100
    text: const Color(0xFF15803D), // green-700
    border: const Color(0xFFBBF7D0), // green-200
  ),
};

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
      child: GestureDetector(
        onTap: onView,
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
                  behavior: HitTestBehavior.opaque,
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
                      if (task.description?.isNotEmpty ?? false) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          task.description!,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.mutedForeground,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.sm),
                      // Created date + more menu
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
                          _MoreButton(onEdit: onEdit, onDelete: onDelete),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date.toLocal());
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
    final config = _priorityConfig[priority] ?? _priorityConfig['medium']!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: config.bg,
        borderRadius: AppBorders.borderRadiusFull,
        border: Border.all(color: config.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        child: Text(
          config.label,
          style: AppTypography.caption.copyWith(
            color: config.text,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}

enum _TaskAction { edit, delete }

class _MoreButton extends StatelessWidget {
  const _MoreButton({required this.onEdit, required this.onDelete});

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: PopupMenuButton<_TaskAction>(
        onSelected: (action) =>
            action == _TaskAction.edit ? onEdit() : onDelete(),
        padding: EdgeInsets.zero,
        iconSize: 15,
        icon: const Icon(
          LucideIcons.moreVertical,
          color: AppColors.mutedForeground,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        itemBuilder: (_) => [
          PopupMenuItem(
            value: _TaskAction.edit,
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.smMd),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.pencil, size: 14, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Sửa',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.foreground,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: _TaskAction.delete,
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.smMd),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.trash2,
                  size: 14,
                  color: AppColors.destructive,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Xóa',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.destructive,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
