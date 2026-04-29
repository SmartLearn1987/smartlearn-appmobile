import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../../core/theme/theme.dart';
import '../../../domain/entities/note_item_entity.dart';

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
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.yellow50,
          borderRadius: AppBorders.borderRadiusLg,
          border: Border.all(
            color: AppColors.border,
            width: AppBorders.widthThick,
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: icon + title + close button
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  LucideIcons.stickyNote,
                  size: 20,
                  color: AppColors.foreground,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    note.title.isNotEmpty ? note.title : 'Chi tiết ghi chú',
                    style: AppTypography.h4.copyWith(
                      color: AppColors.foreground,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(
                    LucideIcons.x,
                    size: 18,
                    color: AppColors.foreground.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Scrollable content
            if (note.content.isNotEmpty)
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.45,
                ),
                child: SingleChildScrollView(
                  child: Text(
                    note.content,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.foreground.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            // Footer
            Divider(color: AppColors.border.withValues(alpha: 0.2)),
            const SizedBox(height: AppSpacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Smart Learn Notes',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.foreground.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  _formatDateTime(note.updatedAt),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.foreground.withValues(alpha: 0.6),
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
