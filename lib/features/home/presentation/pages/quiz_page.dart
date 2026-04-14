import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_learn/core/theme/app_borders.dart';
import 'package:smart_learn/core/theme/app_colors.dart';
import 'package:smart_learn/core/theme/app_shadows.dart';
import 'package:smart_learn/core/theme/app_spacing.dart';
import 'package:smart_learn/core/theme/app_typography.dart';

class QuizPage extends StatelessWidget {
  const QuizPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.mdLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trắc nghiệm',
            style: AppTypography.h2.copyWith(color: AppColors.foreground),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Luyện tập và kiểm tra kiến thức',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _QuizCard(
            icon: LucideIcons.calculator,
            title: 'Toán học cơ bản',
            subtitle: '20 câu hỏi · 15 phút',
            iconColor: AppColors.primary,
            iconBgColor: AppColors.primaryLight,
          ),
          const SizedBox(height: AppSpacing.smMd),
          _QuizCard(
            icon: LucideIcons.flaskConical,
            title: 'Vật lý đại cương',
            subtitle: '15 câu hỏi · 10 phút',
            iconColor: AppColors.accent,
            iconBgColor: AppColors.accentLight,
          ),
          const SizedBox(height: AppSpacing.smMd),
          _QuizCard(
            icon: LucideIcons.globe,
            title: 'English Grammar',
            subtitle: '25 câu hỏi · 20 phút',
            iconColor: AppColors.quiz,
            iconBgColor: AppColors.quizLight,
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  const _QuizCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.iconBgColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color iconBgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppBorders.borderRadiusLg,
        border: Border.all(color: AppColors.border, width: AppBorders.widthThin),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: AppBorders.borderRadiusSm,
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(width: AppSpacing.smMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.foreground,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  subtitle,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            LucideIcons.chevronRight,
            size: 18,
            color: AppColors.mutedForeground,
          ),
        ],
      ),
    );
  }
}
