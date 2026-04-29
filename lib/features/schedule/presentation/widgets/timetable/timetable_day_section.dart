import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/timetable_entry_entity.dart';
import '../../helpers/timetable_helpers.dart';

/// 7 predefined entry colors — same palette as before.
const _entryColors = <Color>[
  Color(0xFF3B82F6),
  Color(0xFF10B981),
  Color(0xFF8B5CF6),
  Color(0xFFF97316),
  Color(0xFFEC4899),
  Color(0xFF06B6D4),
  Color(0xFFEAB308),
];

Color _colorForSubject(String subject) {
  final index =
      subject.codeUnits.fold(0, (sum, c) => sum + c) % _entryColors.length;
  return _entryColors[index];
}

/// Day header colors keyed by day string (matches API values).
const dayHeaderColors = <String, Color>{
  'Thứ 2': Color(0xFF3B82F6),
  'Thứ 3': Color(0xFF10B981),
  'Thứ 4': Color(0xFF8B5CF6),
  'Thứ 5': Color(0xFFF97316),
  'Thứ 6': Color(0xFFEC4899),
  'Thứ 7': Color(0xFF06B6D4),
  'Chủ nhật': Color(0xFFF43F5E),
};

/// Ordered list of day strings for sorting.
const dayOrder = <String>[
  'Thứ 2',
  'Thứ 3',
  'Thứ 4',
  'Thứ 5',
  'Thứ 6',
  'Thứ 7',
  'Chủ nhật',
];

/// Day names for dropdowns (same as dayOrder, kept for backward compat).
const dayNames = dayOrder;

class TimetableDaySection extends StatelessWidget {
  const TimetableDaySection({
    required this.day,
    required this.entries,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final String day;
  final List<TimetableEntryEntity> entries;
  final void Function(TimetableEntryEntity entry) onEdit;
  final void Function(String entryId) onDelete;

  @override
  Widget build(BuildContext context) {
    final headerColor = dayHeaderColors[day] ?? AppColors.primary;
    final sorted = sortEntriesByTime(entries);
    final periods = splitByPeriod(sorted);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Day header ──────────────────────────────────────────────
            Container(
              color: headerColor,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.smMd,
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.calendarDays, size: 16, color: Colors.white),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    day,
                    style: AppTypography.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${entries.length} môn',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),

            // ── Single-column period list ───────────────────────────────
            if (periods.morning.isNotEmpty) ...[
              _PeriodHeader(isMorning: true, count: periods.morning.length),
              ...periods.morning.map(
                (entry) => _EntryRow(
                  entry: entry,
                  onEdit: () => onEdit(entry),
                  onDelete: () => onDelete(entry.id),
                ),
              ),
            ],
            if (periods.afternoon.isNotEmpty) ...[
              if (periods.morning.isNotEmpty)
                Divider(height: 1, thickness: 1, color: AppColors.border),
              _PeriodHeader(isMorning: false, count: periods.afternoon.length),
              ...periods.afternoon.map(
                (entry) => _EntryRow(
                  entry: entry,
                  onEdit: () => onEdit(entry),
                  onDelete: () => onDelete(entry.id),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Period sub-header ─────────────────────────────────────────────────────────

class _PeriodHeader extends StatelessWidget {
  const _PeriodHeader({required this.isMorning, required this.count});

  final bool isMorning;
  final int count;

  @override
  Widget build(BuildContext context) {
    final bgColor = isMorning
        ? const Color(0xFFFFFBEB) // amber-50
        : const Color(0xFFEFF6FF); // blue-50

    return Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.smMd,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Text(isMorning ? '☀' : '🌙', style: const TextStyle(fontSize: 13)),
          const SizedBox(width: AppSpacing.xs),
          Text(
            isMorning ? 'SÁNG' : 'CHIỀU',
            style: AppTypography.labelSmall.copyWith(
              color: isMorning
                  ? const Color(0xFFD97706) // amber-600
                  : const Color(0xFF2563EB), // blue-600
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          Text(
            '$count tiết',
            style: AppTypography.caption.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Entry row ─────────────────────────────────────────────────────────────────

class _EntryRow extends StatelessWidget {
  const _EntryRow({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  final TimetableEntryEntity entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = _colorForSubject(entry.subject);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(height: 1, thickness: 1),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.smMd,
            vertical: AppSpacing.smMd,
          ),
          child: Row(
            children: [
              // Subject pill
              _SubjectPill(subject: entry.subject, color: color),
              const SizedBox(width: AppSpacing.sm),

              // Clock + time
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.clock,
                      size: 13,
                      color: AppColors.mutedForeground,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${entry.startTime} – ${entry.endTime}',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (entry.room?.isNotEmpty == true) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Icon(
                        LucideIcons.bookOpen,
                        size: 13,
                        color: AppColors.mutedForeground,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        entry.room!,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Edit button
              GestureDetector(
                onTap: onEdit,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  child: Icon(
                    LucideIcons.pencil,
                    size: 15,
                    color: AppColors.primary,
                  ),
                ),
              ),
              // Delete button
              GestureDetector(
                onTap: onDelete,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  child: Icon(
                    LucideIcons.trash2,
                    size: 15,
                    color: AppColors.destructive,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Subject pill ──────────────────────────────────────────────────────────────

class _SubjectPill extends StatelessWidget {
  const _SubjectPill({required this.subject, required this.color});

  final String subject;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.25)),
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        subject,
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }
}
