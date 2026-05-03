import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_learn/core/theme/app_borders.dart';
import 'package:smart_learn/core/theme/app_colors.dart';
import 'package:smart_learn/core/theme/app_shadows.dart';
import 'package:smart_learn/core/theme/app_spacing.dart';
import 'package:smart_learn/core/theme/app_typography.dart';
import 'package:smart_learn/router/route_names.dart';

import '../models/subject_with_count.dart';

class SubjectCardWidget extends StatelessWidget {
  const SubjectCardWidget({required this.subjectWithCount, super.key});

  final SubjectWithCount subjectWithCount;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      builder: (context, opacity, child) =>
          Opacity(opacity: opacity, child: child),
      child: GestureDetector(
        onTap: () =>
            context.push(RoutePaths.subjectDetail(subjectWithCount.subject.id)),
        child: ClipRRect(
          borderRadius: AppBorders.borderRadiusLg,
          child: Stack(
            children: [
              // ─── Content ───
              Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.smMd),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.smMd,
                ),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: AppBorders.borderRadiusLg,
                  boxShadow: AppShadows.card,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subjectWithCount.icon, style: AppTypography.text3Xl),
                    const SizedBox(height: AppSpacing.smMd),
                    Text(
                      subjectWithCount.subject.name,
                      style: AppTypography.h3,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      subjectWithCount.description,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Chip(
                      padding: EdgeInsets.zero,
                      label: Text(
                        '${subjectWithCount.userCurriculumCount} giáo trình',
                        style: AppTypography.buttonSmall.copyWith(
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // ─── Decorative circle ───
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.08),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
