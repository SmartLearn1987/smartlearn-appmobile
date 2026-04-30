import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
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
    return GestureDetector(
      onTap: onView,
      child: DecoratedBox(
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
              // Date + more menu
              Row(
                children: [
                  Expanded(
                    child: Text(
                      DateFormat(
                        'dd/MM/yyyy HH:mm',
                      ).format(note.updatedAt.toLocal()),
                      style: AppTypography.textXs.withColor(
                        AppColors.mutedForeground,
                      ),
                    ),
                  ),
                  _MoreButton(onEdit: onEdit, onDelete: onDelete),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _NoteAction { edit, delete }

class _MoreButton extends StatelessWidget {
  const _MoreButton({required this.onEdit, required this.onDelete});

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: PopupMenuButton<_NoteAction>(
        onSelected: (action) =>
            action == _NoteAction.edit ? onEdit() : onDelete(),
        padding: EdgeInsets.zero,
        iconSize: 15,
        icon: const Icon(
          LucideIcons.moreVertical,
          color: AppColors.mutedForeground,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        itemBuilder: (_) => [
          PopupMenuItem(
            value: _NoteAction.edit,
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
            value: _NoteAction.delete,
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
