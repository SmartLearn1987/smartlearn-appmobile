import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../../core/theme/app_borders.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/note_item_entity.dart';

/// 12 note colors — light (background) and dark (border/text).
const noteColorsLight = <Color>[
  Color(0xFFFEF9C3),
  Color(0xFFDBEAFE),
  Color(0xFFDCFCE7),
  Color(0xFFFCE7F3),
  Color(0xFFEDE9FE),
  Color(0xFFFFEDD5),
  Color(0xFFCA8A04),
  Color(0xFF2563EB),
  Color(0xFF16A34A),
  Color(0xFFDB2777),
  Color(0xFF7C3AED),
  Color(0xFFEA580C),
];

const noteColorsDark = <Color>[
  Color(0xFFCA8A04),
  Color(0xFF2563EB),
  Color(0xFF16A34A),
  Color(0xFFDB2777),
  Color(0xFF7C3AED),
  Color(0xFFEA580C),
  Color(0xFF854D0E),
  Color(0xFF1E40AF),
  Color(0xFF166534),
  Color(0xFF9D174D),
  Color(0xFF5B21B6),
  Color(0xFF9A3412),
];

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
    final colorIndex = note.color % noteColorsLight.length;
    final bgColor = noteColorsLight[colorIndex];
    final borderColor = noteColorsDark[colorIndex];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppBorders.borderRadiusLg,
        border: Border.all(color: borderColor, width: AppBorders.widthThin),
      ),
      child: Padding(
        padding: AppSpacing.paddingSm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            if (note.title.isNotEmpty)
              Text(
                note.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelMedium.copyWith(
                  color: borderColor,
                ),
              ),
            if (note.title.isNotEmpty) const SizedBox(height: AppSpacing.xs),
            // Content preview
            if (note.content.isNotEmpty)
              Expanded(
                child: Text(
                  note.content,
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    color: borderColor.withValues(alpha: 0.85),
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.sm),
            // Updated date
            Text(
              _formatDate(note.updatedAt),
              style: AppTypography.caption.copyWith(
                color: borderColor.withValues(alpha: 0.6),
                fontSize: 10,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _ActionButton(
                  icon: LucideIcons.eye,
                  onTap: onView,
                  color: borderColor,
                ),
                const SizedBox(width: AppSpacing.xs),
                _ActionButton(
                  icon: LucideIcons.pencil,
                  onTap: onEdit,
                  color: borderColor,
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
