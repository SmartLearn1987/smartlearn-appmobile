import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
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
          _buildTopRow(),
          const Divider(height: AppSpacing.mdLg),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildTopRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCoverImage(),
        const SizedBox(width: AppSpacing.smMd),
        Expanded(child: _buildInfo()),
      ],
    );
  }

  Widget _buildCoverImage() {
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: curriculum.imageUrl != null
                ? AppCachedImage(
                    imageUrl: curriculum.imageUrl!,
                    width: 64,
                    height: 64,
                    borderRadius: BorderRadius.circular(12),
                    errorWidget: _buildFallbackIcon(),
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

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                curriculum.name,
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(
              curriculum.isPublic ? LucideIcons.eye : LucideIcons.eyeOff,
              size: 16,
              color: curriculum.isPublic
                  ? const Color(0xFF3b82f6)
                  : const Color(0xFFf59e0b),
            ),
          ],
        ),
        if (curriculum.grade != null) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'Lớp ${curriculum.grade}',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
        ],
        if (curriculum.publisher != null) ...[
          const SizedBox(height: AppSpacing.xxs),
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
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onManageLessons,
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
            child: const Text('Quản lý bài học'),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        _IconActionButton(icon: LucideIcons.pencil, onPressed: onEdit),
        const SizedBox(width: AppSpacing.xs),
        _IconActionButton(
          icon: LucideIcons.trash2,
          onPressed: onDelete,
          hoverColor: AppColors.destructive,
        ),
      ],
    );
  }
}

class _IconActionButton extends StatelessWidget {
  const _IconActionButton({
    required this.icon,
    this.onPressed,
    this.hoverColor,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final Color? hoverColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        style: IconButton.styleFrom(
          foregroundColor: hoverColor ?? AppColors.mutedForeground,
          shape: RoundedRectangleBorder(
            borderRadius: AppBorders.borderRadiusSm,
            side: const BorderSide(
              color: AppColors.border,
              width: AppBorders.widthThin,
            ),
          ),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
