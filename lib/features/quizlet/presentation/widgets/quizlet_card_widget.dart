import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_learn/core/theme/app_borders.dart';
import 'package:smart_learn/core/theme/app_colors.dart';
import 'package:smart_learn/core/theme/app_shadows.dart';
import 'package:smart_learn/core/theme/app_spacing.dart';
import 'package:smart_learn/core/theme/app_typography.dart';
import 'package:smart_learn/core/theme/text_style_extensions.dart';
import 'package:smart_learn/features/quizlet/domain/entities/quizlet_entity.dart';
import 'package:smart_learn/features/quizlet/presentation/helpers/quizlet_filter_helper.dart';

class QuizletCardWidget extends StatelessWidget {
  final QuizletEntity quizlet;
  final ViewMode viewMode;
  final String currentUserId;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const QuizletCardWidget({
    super.key,
    required this.quizlet,
    required this.viewMode,
    required this.currentUserId,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isOwner = quizlet.userId == currentUserId;
    final showOwnerBadge = viewMode == ViewMode.community && isOwner;
    final showVisibilityIcon = viewMode == ViewMode.personal;
    final showMenu = viewMode == ViewMode.personal;

    return InkWell(
      onTap: onTap,
      borderRadius: AppBorders.borderRadiusMd,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppBorders.borderRadiusMd,
          boxShadow: AppShadows.card,
        ),
        padding: AppSpacing.paddingCard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.gray400.withValues(alpha: 0.1),
                  ),
                  child: Icon(
                    LucideIcons.layers,
                    size: AppSpacing.mdLg,
                    color: AppColors.gray400,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    quizlet.title,
                    style: AppTypography.bodyLarge.bold.copyWith(
                      color: AppColors.foreground,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (showOwnerBadge)
                  Container(
                    margin: const EdgeInsets.only(left: AppSpacing.sm),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppSpacing.lg),
                    ),
                    child: Text(
                      'Của bạn',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primaryForeground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                Row(
                  children: [
                    if (showVisibilityIcon)
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: quizlet.isPublic
                                ? AppColors.blue600
                                : AppColors.secondary,
                            width: AppBorders.widthThin,
                          ),
                          color: quizlet.isPublic
                              ? AppColors.blue600Light
                              : AppColors.secondaryLight,
                        ),
                        child: Icon(
                          quizlet.isPublic
                              ? LucideIcons.eye
                              : LucideIcons.eyeOff,
                          size: AppSpacing.mdLg,
                          color: quizlet.isPublic
                              ? AppColors.blue600
                              : AppColors.secondary,
                        ),
                      ),
                    if (showMenu)
                      PopupMenuButton<String>(
                        icon: const Icon(LucideIcons.moreVertical),
                        onSelected: (value) {
                          if (value == 'edit') {
                            onEdit();
                          } else if (value == 'delete') {
                            onDelete();
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem<String>(
                            value: 'edit',
                            child: ListTile(
                              leading: Icon(LucideIcons.edit),
                              title: Text('Chỉnh sửa'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(LucideIcons.trash),
                              title: Text('Xóa học phần'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
            const Divider(height: AppSpacing.mdLg),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.bookOpen,
                      size: AppSpacing.md,
                      color: AppColors.mutedForeground,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${quizlet.termCount} thuật ngữ',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      LucideIcons.user,
                      size: AppSpacing.md,
                      color: AppColors.mutedForeground,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      quizlet.authorName,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
