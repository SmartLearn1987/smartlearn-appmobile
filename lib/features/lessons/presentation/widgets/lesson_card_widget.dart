import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/lesson_entity.dart';

/// Displays a lesson card with index, title, and description.
///
/// Supports two modes:
/// - **Manage mode** (`isReviewMode: false`): Shows "Sửa" and "Xóa" action
///   buttons for editing and deleting.
/// - **Review mode** (`isReviewMode: true`): Shows a "Đã học" completion badge
///   when [isCompleted] is `true`, and the entire card is tappable.
class LessonCardWidget extends StatelessWidget {
  const LessonCardWidget({
    super.key,
    required this.lesson,
    required this.index,
    this.isReviewMode = false,
    this.isCompleted = false,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  final LessonEntity lesson;
  final int index;
  final bool isReviewMode;
  final bool isCompleted;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(AppSpacing.smMd),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppBorders.borderRadiusLg,
        border: Border.all(
          color: AppColors.border,
          width: AppBorders.widthThin,
        ),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopRow(),
          if (!isReviewMode) ...[
            const Divider(height: AppSpacing.mdLg),
            _buildManageActions(),
          ],
        ],
      ),
    );

    if (isReviewMode) {
      return GestureDetector(onTap: onTap, child: card);
    }

    return card;
  }

  Widget _buildTopRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildInfo()),
        if (isReviewMode && isCompleted) ...[
          const SizedBox(width: AppSpacing.sm),
          _buildCompletionBadge(),
        ],
      ],
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${index + 1}. ${lesson.title}",
          style: AppTypography.h4.copyWith(fontWeight: FontWeight.w700),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          lesson.description ?? "Không có mô tả nội dung bài học",
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.mutedForeground,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildCompletionBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: AppBorders.borderRadiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            LucideIcons.checkCircle,
            size: 14,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Đã học',
            style: AppTypography.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManageActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onEdit,
            icon: const Icon(LucideIcons.pencil, size: 14),
            label: const Text('Sửa'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.foreground,
              textStyle: AppTypography.buttonSmall,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: AppBorders.borderRadiusSm,
              ),
              side: const BorderSide(
                color: AppColors.border,
                width: AppBorders.widthThin,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onDelete,
            icon: const Icon(LucideIcons.trash2, size: 14),
            label: const Text('Xóa'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.destructive,
              textStyle: AppTypography.buttonSmall,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: AppBorders.borderRadiusSm,
              ),
              side: const BorderSide(
                color: AppColors.destructive,
                width: AppBorders.widthThin,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
