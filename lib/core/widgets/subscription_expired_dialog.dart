import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_learn/core/subscription/open_premium_in_web_view.dart';
import 'package:smart_learn/core/theme/app_borders.dart';
import 'package:smart_learn/core/theme/app_colors.dart';
import 'package:smart_learn/core/theme/app_spacing.dart';
import 'package:smart_learn/core/theme/app_typography.dart';

/// Modal « Hết hạn gói cước » — khớp copy và CTA như Index web.
Future<void> showSubscriptionExpiredDialog(BuildContext anchoredContext) {
  return showDialog<void>(
    context: anchoredContext,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE8F5EC),
                  Color(0xFFFFFFFF),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withValues(alpha: 0.12),
                        ),
                        child: const Icon(
                          LucideIcons.alertTriangle,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                      Positioned(
                        right: -6,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFFFFF),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x1A000000),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              LucideIcons.crown,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Hết hạn gói cước',
                    textAlign: TextAlign.center,
                    style: AppTypography.h2.copyWith(
                      color: const Color(0xFF111827),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Gói thành viên của bạn đã hết hạn sử dụng. Hãy nâng cấp để tiếp tục học tập và sử dụng toàn bộ tính năng của Smart Learn.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(
                      color: const Color(0xFF4B5563),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.primaryForeground,
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.smMd),
                        shape: AppBorders.shapeLg,
                        elevation: 4,
                      ),
                      onPressed: () async {
                        Navigator.of(dialogContext).pop();
                        if (anchoredContext.mounted) {
                          await openPremiumUpgradeInWebView(anchoredContext);
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.crown, size: 22),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Nâng cấp ngay',
                            style: AppTypography.buttonLarge.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.smMd),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF6B7280),
                      minimumSize: const Size(double.infinity, 48),
                      shape: AppBorders.shapeLg,
                    ),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(
                      'Để sau',
                      style: AppTypography.buttonLarge.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
