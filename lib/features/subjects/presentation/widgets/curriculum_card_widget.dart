import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_learn/core/theme/theme.dart';

import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/photo_gallery/show_photo_gallery.dart';
import '../../../../core/widgets/app_cached_image.dart';
import '../../domain/entities/curriculum_entity.dart';

class CurriculumCardWidget extends StatelessWidget {
  const CurriculumCardWidget({
    required this.curriculum,
    required this.index,
    this.onManageLessons,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  final CurriculumEntity curriculum;
  final int index;
  final VoidCallback? onManageLessons;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          _buildTopRow(context),
          const Divider(height: AppSpacing.mdLg),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildTopRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCoverImage(context),
        const SizedBox(width: AppSpacing.smMd),
        Expanded(child: _buildInfo(context)),
      ],
    );
  }

  Widget _buildCoverImage(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: curriculum.imageUrl != null
                ? GestureDetector(
                    onTap: () => showPhotoGallery(
                      context,
                      items: [PhotoGalleryNetworkUrl(curriculum.imageUrl!)],
                    ),
                    behavior: HitTestBehavior.opaque,
                    child: AppCachedImage(
                      imageUrl: curriculum.imageUrl!,
                      width: 64,
                      height: 64,
                      borderRadius: BorderRadius.circular(12),
                      errorWidget: _buildFallbackIcon(),
                    ),
                  )
                : _buildFallbackIcon(),
          ),
          Positioned(
            top: -4,
            left: -4,
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '${index + 1}',
                style: AppTypography.caption.copyWith(
                  color: AppColors.primaryForeground,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        LucideIcons.bookOpen,
        color: AppColors.primary,
        size: 28,
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    final hasMenu = onEdit != null || onDelete != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                curriculum.name,
                style: AppTypography.labelLarge.bold,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasMenu) ...[
              const SizedBox(width: AppSpacing.xs),
              SizedBox(
                width: 32,
                height: 32,
                child: PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  iconSize: 20,
                  icon: const Icon(
                    LucideIcons.moreVertical,
                    color: AppColors.mutedForeground,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onSelected: (value) {
                    if (value == 'edit') onEdit?.call();
                    if (value == 'delete') onDelete?.call();
                  },
                  itemBuilder: (ctx) => [
                    if (onEdit != null)
                      PopupMenuItem<String>(
                        value: 'edit',
                        height: 36,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.smMd,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.pencil,
                              size: 20,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'Chỉnh sửa',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.foreground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (onDelete != null)
                      PopupMenuItem<String>(
                        value: 'delete',
                        height: 36,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.smMd,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.trash2,
                              size: 20,
                              color: AppColors.destructive,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'Xóa giáo trình',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.destructive,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
        if (curriculum.grade != null) ...[
          Text(
            'Lớp ${curriculum.grade}',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
        ],
        if (curriculum.publisher != null) ...[
          if (curriculum.grade != null) const SizedBox(height: AppSpacing.xxs),
          Text(
            'NXB: ${curriculum.publisher}',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: AppBorders.borderRadiusSm,
          ),
          child: Text(
            '${curriculum.lessonCount} bài học',
            style: AppTypography.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.5),
            width: AppBorders.widthThin,
          ),
          textStyle: AppTypography.buttonMedium,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
        ),
        onPressed: onManageLessons,
        child: const Text('Quản lý bài học'),
      ),
    );
  }
}
