import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_learn/core/theme/app_colors.dart';
import 'package:smart_learn/core/theme/app_spacing.dart';
import 'package:smart_learn/core/theme/app_typography.dart';
import 'package:smart_learn/features/home/presentation/widgets/subject_detail_card.dart';

class SubjectsPage extends StatelessWidget {
  const SubjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.mdLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Các môn học',
            style: AppTypography.h2.copyWith(color: AppColors.foreground),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Ghi chép, lưu trữ bài học của bạn, giúp ôn tập tốt hơn!',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: SubjectDetailCard(
                  icon: LucideIcons.calculator,
                  title: 'Toán học',
                  description: 'Đại số, Hình học, Giải tích',
                  courseCount: '12 khóa học',
                  iconColor: AppColors.primary,
                  iconBgColor: AppColors.primaryLight,
                  badgeColor: AppColors.primary,
                  badgeBgColor: const Color(0x152D9B63),
                ),
              ),
              const SizedBox(width: AppSpacing.mdLg),
              Expanded(
                child: SubjectDetailCard(
                  icon: LucideIcons.flaskConical,
                  title: 'Vật lý',
                  description: 'Cơ học, Điện từ, Quang học',
                  courseCount: '8 khóa học',
                  iconColor: AppColors.accent,
                  iconBgColor: AppColors.accentLight,
                  badgeColor: AppColors.accent,
                  badgeBgColor: const Color(0x152FA3D9),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.mdLg),
          Row(
            children: [
              Expanded(
                child: SubjectDetailCard(
                  icon: LucideIcons.bookMarked,
                  title: 'Ngữ văn',
                  description: 'Văn bản, Nghị luận, Thơ ca',
                  courseCount: '10 khóa học',
                  iconColor: AppColors.secondary,
                  iconBgColor: AppColors.secondaryLight,
                  badgeColor: AppColors.secondary,
                  badgeBgColor: const Color(0x15F0943E),
                ),
              ),
              const SizedBox(width: AppSpacing.mdLg),
              Expanded(
                child: SubjectDetailCard(
                  icon: LucideIcons.globe,
                  title: 'Tiếng Anh',
                  description: 'Grammar, Vocabulary, Speaking',
                  courseCount: '15 khóa học',
                  iconColor: AppColors.quiz,
                  iconBgColor: AppColors.quizLight,
                  badgeColor: AppColors.quiz,
                  badgeBgColor: const Color(0x159645CC),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
