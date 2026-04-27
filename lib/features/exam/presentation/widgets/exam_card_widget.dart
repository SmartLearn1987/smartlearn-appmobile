import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_learn/core/theme/app_borders.dart';
import 'package:smart_learn/core/theme/app_colors.dart';
import 'package:smart_learn/core/theme/app_shadows.dart';
import 'package:smart_learn/core/theme/app_spacing.dart';
import 'package:smart_learn/core/theme/app_typography.dart';
import 'package:smart_learn/features/exam/domain/entities/exam_entity.dart';
import 'package:smart_learn/router/route_names.dart';

class ExamCardWidget extends StatelessWidget {
  const ExamCardWidget({
    super.key,
    required this.exam,
    required this.isPersonal,
    required this.onEdit,
    required this.onDelete,
  });

  final ExamEntity exam;
  final bool isPersonal;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(RoutePaths.examDetail(exam.id)),
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
                Container(
                  width: AppSpacing.xxxl,
                  height: AppSpacing.xxxl,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.1),
                  ),
                  child: const Icon(
                    LucideIcons.clipboardList,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.smMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exam.title,
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.foreground,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        exam.subjectName,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isPersonal)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: exam.isPublic
                              ? Colors.blue.withValues(alpha: 0.1)
                              : Colors.orange.withValues(alpha: 0.15),
                          borderRadius: AppBorders.borderRadiusFull,
                        ),
                        child: Icon(
                          exam.isPublic ? LucideIcons.eye : LucideIcons.eyeOff,
                          size: AppSpacing.smMd,
                          color: exam.isPublic ? Colors.blue : Colors.orange,
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(
                          LucideIcons.moreVertical,
                          size: AppSpacing.mdLg,
                        ),
                        onSelected: (value) {
                          if (value == 'edit') onEdit();
                          if (value == 'delete') onDelete();
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem<String>(
                            value: 'edit',
                            child: Text('Chỉnh sửa'),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Text('Xóa bài thi'),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
            if ((exam.description ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                exam.description!.trim(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
            if (exam.averageScore != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.smMd,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7E6),
                  borderRadius: AppBorders.borderRadiusSm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.trophy,
                      size: AppSpacing.md,
                      color: Color(0xFFB45309),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Điểm TB: ${exam.averageScore!.round()}%',
                      style: AppTypography.caption.copyWith(
                        color: const Color(0xFF92400E),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const Divider(height: AppSpacing.mdLg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _MetaItem(
                  icon: LucideIcons.clipboardList,
                  label: '${exam.questionCount} câu hỏi',
                ),
                _MetaItem(
                  icon: LucideIcons.clock,
                  label: '${exam.duration} phút',
                ),
                _MetaItem(icon: LucideIcons.user, label: exam.authorName),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push(RoutePaths.examDetail(exam.id)),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  shape: AppBorders.shapeSm,
                ),
                child: Text(
                  'Làm bài',
                  style: AppTypography.buttonMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppSpacing.md, color: AppColors.mutedForeground),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }
}
