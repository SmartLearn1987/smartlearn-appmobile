import 'package:flutter/material.dart';
import 'package:smart_learn/core/theme/app_borders.dart';
import 'package:smart_learn/core/theme/app_colors.dart';
import 'package:smart_learn/core/theme/app_shadows.dart';
import 'package:smart_learn/core/theme/app_spacing.dart';
import 'package:smart_learn/core/theme/app_typography.dart';

/// Detailed subject card matching the Subjects Screen design.
/// Shows icon, title, description, and a course count badge.
class SubjectDetailCard extends StatelessWidget {
  const SubjectDetailCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.courseCount,
    required this.iconColor,
    required this.iconBgColor,
    required this.badgeColor,
    required this.badgeBgColor,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;
  final String courseCount;
  final Color iconColor;
  final Color iconBgColor;
  final Color badgeColor;
  final Color badgeBgColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.mdLg),
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
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: AppBorders.borderRadiusMd,
              ),
              child: Icon(icon, size: 24, color: iconColor),
            ),
            const SizedBox(height: AppSpacing.smMd),
            Text(
              title,
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.foreground,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              description,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.mutedForeground,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: AppSpacing.smMd),
            Container(
              height: 24,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: badgeBgColor,
                borderRadius: AppBorders.borderRadiusFull,
              ),
              alignment: Alignment.center,
              child: Text(
                courseCount,
                style: AppTypography.buttonSmall.copyWith(
                  fontSize: 11,
                  color: badgeColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
