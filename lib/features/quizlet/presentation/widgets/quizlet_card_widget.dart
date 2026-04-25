import 'package:flutter/material.dart';
import 'package:smart_learn/core/theme/app_borders.dart';
import 'package:smart_learn/core/theme/app_colors.dart';
import 'package:smart_learn/core/theme/app_shadows.dart';
import 'package:smart_learn/core/theme/app_spacing.dart';
import 'package:smart_learn/core/theme/app_typography.dart';
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    quizlet.title,
                    style: AppTypography.labelLarge.copyWith(
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
                if (showVisibilityIcon)
                  Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.sm),
                    child: Icon(
                      quizlet.isPublic ? Icons.visibility : Icons.visibility_off,
                      size: AppSpacing.md,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                if (showMenu)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
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
                          leading: Icon(Icons.edit),
                          title: Text('Chỉnh sửa'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete_outline),
                          title: Text('Xóa học phần'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              quizlet.subjectName ?? '',
              style: AppTypography.bodySmall.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(
                  Icons.style_outlined,
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
                const SizedBox(width: AppSpacing.md),
                Icon(
                  Icons.person_outline,
                  size: AppSpacing.md,
                  color: AppColors.mutedForeground,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    quizlet.authorName,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                    overflow: TextOverflow.ellipsis,
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
