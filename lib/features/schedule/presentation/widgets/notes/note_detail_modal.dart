import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../../core/theme/app_borders.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/note_item_entity.dart';
import 'note_item_card.dart';

class NoteDetailModal extends StatelessWidget {
  const NoteDetailModal({required this.note, super.key});

  final NoteItemEntity note;

  String _formatDateTime(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final h = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');
    return '$d/$m/${date.year} $h:$min';
  }

  @override
  Widget build(BuildContext context) {
    final colorIndex = note.color % noteColorsLight.length;
    final bgColor = noteColorsLight[colorIndex];
    final borderColor = noteColorsDark[colorIndex];

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppBorders.radiusLg),
        ),
        border: Border.all(color: borderColor, width: AppBorders.widthThin),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
          left: AppSpacing.md,
          right: AppSpacing.md,
          top: AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: borderColor.withValues(alpha: 0.3),
                  borderRadius: AppBorders.borderRadiusFull,
                ),
                child: const SizedBox(width: 40, height: 4),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Title with sticky note icon
            Row(
              children: [
                Icon(LucideIcons.stickyNote, size: 20, color: borderColor),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    note.title.isNotEmpty ? note.title : 'Chi tiết ghi chú',
                    style: AppTypography.h4.copyWith(color: borderColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Scrollable content
            if (note.content.isNotEmpty)
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: SingleChildScrollView(
                  child: Text(
                    note.content,
                    style: AppTypography.bodyMedium.copyWith(
                      color: borderColor.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            // Footer
            Divider(color: borderColor.withValues(alpha: 0.2)),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Smart Learn Notes',
                  style: AppTypography.caption.copyWith(
                    color: borderColor.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  _formatDateTime(note.updatedAt),
                  style: AppTypography.caption.copyWith(
                    color: borderColor.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
