import 'package:flutter/material.dart';
import 'package:smart_learn/core/theme/app_borders.dart';
import 'package:smart_learn/core/theme/app_colors.dart';
import 'package:smart_learn/core/theme/app_shadows.dart';
import 'package:smart_learn/core/theme/app_spacing.dart';
import 'package:smart_learn/core/theme/app_typography.dart';

class GameCardWidget extends StatelessWidget {
  const GameCardWidget({
    required this.title,
    required this.description,
    required this.image,
    required this.isAvailable,
    this.onTap,
    super.key,
  });

  final String title;
  final String description;
  final String image;
  final bool isAvailable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      builder: (context, opacity, child) =>
          Opacity(opacity: opacity, child: child),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: AppBorders.borderRadiusLg,
            boxShadow: AppShadows.card,
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.smMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: AppBorders.borderRadiusLg,
                  child: Image.asset(image, width: 56, height: 56),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  title,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.foreground,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  description,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  height: 32,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAvailable
                          ? AppColors.primary
                          : AppColors.muted,
                      foregroundColor: isAvailable
                          ? Colors.white
                          : AppColors.mutedForeground,
                      shape: AppBorders.shapeSm,
                      padding: EdgeInsets.zero,
                      textStyle: AppTypography.buttonSmall,
                    ),
                    child: Text(isAvailable ? 'Bắt đầu' : 'Sắp ra mắt'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
