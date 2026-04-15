import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../../core/theme/app_borders.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/timetable_entry_entity.dart';

/// 7 predefined timetable entry colors.
const timetableEntryColors = <Color>[
  Color(0xFF3B82F6),
  Color(0xFF10B981),
  Color(0xFF8B5CF6),
  Color(0xFFF97316),
  Color(0xFFEC4899),
  Color(0xFF06B6D4),
  Color(0xFFEAB308),
];

class TimetableEntryCard extends StatelessWidget {
  const TimetableEntryCard({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final TimetableEntryEntity entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final entryColor = timetableEntryColors[entry.color % timetableEntryColors.length];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppBorders.borderRadiusLg,
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: AppSpacing.paddingSm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _SubjectBadge(subject: entry.subject, color: entryColor)),
                const SizedBox(width: AppSpacing.sm),
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
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(LucideIcons.clock, size: 14, color: AppColors.mutedForeground),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${entry.startTime} - ${entry.endTime}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
            if (entry.room.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Icon(LucideIcons.bookOpen, size: 14, color: AppColors.mutedForeground),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    entry.room,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SubjectBadge extends StatelessWidget {
  const _SubjectBadge({required this.subject, required this.color});

  final String subject;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppBorders.borderRadiusSm,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          subject,
          style: AppTypography.labelSmall.copyWith(color: color),
          overflow: TextOverflow.ellipsis,
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
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}
