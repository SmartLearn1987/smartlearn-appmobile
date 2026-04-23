import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_learn/core/theme/theme.dart';

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
          width: double.infinity,
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
                  style: AppTypography.h4.bold.copyWith(
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
                if (isAvailable)
                  GestureDetector(
                    onTap: onTap,
                    child: SizedBox(
                      height: 32,
                      child: ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryLight,
                          foregroundColor: AppColors.primary,
                          shape: AppBorders.shapeSm,
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          textStyle: AppTypography.buttonSmall,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Bắt đầu'),
                            Icon(
                              LucideIcons.chevronRight,
                              size: 16,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  Text(
                    'Sắp ra mắt',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.mutedForeground,
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
