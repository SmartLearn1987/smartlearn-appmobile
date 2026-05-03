import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_learn/core/theme/theme.dart';

import '../../domain/entities/lesson_entity.dart';

/// Displays a lesson card with index, title, and description.
///
/// Supports two modes:
/// - **Manage mode** (`isReviewMode: false`): Menu (⋯) beside the title; footer
///   shows creation date chip.
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
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.emerald50.withValues(alpha: 0.3)
            : AppColors.card,
        borderRadius: AppBorders.borderRadiusLg,
        border: Border.all(
          color: isCompleted
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.border,
          width: AppBorders.widthThin,
        ),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfo(),
          if (!isReviewMode) ...[
            const Divider(height: AppSpacing.mdLg),
            _buildManageFooter(),
          ],
          if (isReviewMode) ...[
            const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  0,
                  AppSpacing.xs,
                  AppSpacing.xs,
                  AppSpacing.xs,
                ),
                child: Row(
                  children: [
                    Text(
                      isCompleted ? 'ÔN TẬP LẠI' : 'HỌC NGAY',
                      style: AppTypography.textXs.bold.withColor(
                        AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    const Icon(
                      LucideIcons.arrowRight,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (isReviewMode) {
      return GestureDetector(onTap: onTap, child: card);
    }

    return card;
  }

  Widget _buildInfo() {
    final titleStyle = AppTypography.h4.copyWith(fontWeight: FontWeight.w700);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (isReviewMode)
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    (index + 1).toString(),
                    style: AppTypography.textBase.bold.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              if (isReviewMode && isCompleted) ...[
                const Spacer(),
                _buildCompletionBadge(),
              ],
            ],
          ),
        const SizedBox(height: AppSpacing.sm),
        if (isReviewMode)
          Text(
            lesson.title,
            style: titleStyle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '${index + 1}. ${lesson.title}',
                  style: titleStyle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildManageMenuButton(),
            ],
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
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.emerald100,
        borderRadius: AppBorders.borderRadiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            LucideIcons.checkCircle2,
            size: 12,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Đã học',
            style: AppTypography.textXs.bold.withColor(AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildManageFooter() {
    final dateText = lesson.createdAt != null
        ? DateFormat('d/M/yyyy').format(lesson.createdAt!.toLocal())
        : '—';

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.gray100,
          borderRadius: BorderRadius.circular(AppSpacing.lg),
        ),
        child: Text(
          'Ngày tạo: $dateText',
          style: AppTypography.textXs.semiBold.copyWith(
            color: AppColors.mutedForeground,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildManageMenuButton() {
    return SizedBox(
      width: 28,
      height: 28,
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        iconSize: 20,
        icon: const Icon(
          LucideIcons.moreVertical,
          color: AppColors.mutedForeground,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onSelected: (value) {
          if (value == 'edit') onEdit?.call();
          if (value == 'delete') onDelete?.call();
        },
        itemBuilder: (_) => [
          PopupMenuItem<String>(
            value: 'edit',
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.smMd),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  LucideIcons.pencil,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Chỉnh sửa',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.foreground,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'delete',
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.smMd),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  LucideIcons.trash2,
                  size: 14,
                  color: AppColors.destructive,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Xóa bài học',
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
