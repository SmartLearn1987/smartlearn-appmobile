import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_learn/core/theme/app_colors.dart';
import 'package:smart_learn/core/theme/app_spacing.dart';
import 'package:smart_learn/core/theme/app_typography.dart';

class AppCustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppCustomAppBar({
    this.onAvatarTap,
    this.avatarInitial = 'U',
    super.key,
  });

  final VoidCallback? onAvatarTap;
  final String avatarInitial;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.mdLg),
        child: Row(
          children: [
            // ─── Brand ───
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.brandBrownLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                LucideIcons.library,
                size: 18,
                color: AppColors.brandBrown,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Smart Learn',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            // ─── Avatar ───
            GestureDetector(
              onTap: onAvatarTap,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  avatarInitial,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primaryForeground,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
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
