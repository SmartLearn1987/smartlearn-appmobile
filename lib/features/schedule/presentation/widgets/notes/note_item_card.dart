import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_learn/core/theme/theme.dart';

import '../../../domain/entities/note_item_entity.dart';

class NoteItemCard extends StatelessWidget {
  const NoteItemCard({
    required this.note,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final NoteItemEntity note;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.yellow50,
        borderRadius: AppBorders.borderRadiusLg,
        border: Border.all(
          color: AppColors.border,
          width: AppBorders.widthThick,
        ),
      ),
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            if (note.title.isNotEmpty)
              Text(
                note.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelMedium.bold,
              ),
            if (note.title.isNotEmpty) const Divider(height: AppSpacing.md),
            // Content preview
            if (note.content.isNotEmpty)
              Expanded(
                child: Text(
                  note.content,
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall,
                ),
              ),
            const SizedBox(height: AppSpacing.sm),
            // Updated date

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: Text(
                    _formatDate(note.updatedAt),
                    style: AppTypography.textXs.withColor(
                      AppColors.mutedForeground,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                _ActionButton(
                  icon: LucideIcons.eye,
                  onTap: onView,
                  color: AppColors.foreground,
                ),
                const SizedBox(width: AppSpacing.xs),
                _ActionButton(
                  icon: LucideIcons.pencil,
                  onTap: onEdit,
                  color: AppColors.foreground,
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
    );
  }

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
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
