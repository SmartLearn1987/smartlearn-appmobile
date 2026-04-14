import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:smart_learn/core/theme/app_borders.dart';
import 'package:smart_learn/core/theme/app_colors.dart';
import 'package:smart_learn/core/theme/app_shadows.dart';
import 'package:smart_learn/core/theme/app_spacing.dart';
import 'package:smart_learn/core/theme/app_typography.dart';

class HomeCategoryTabs extends StatelessWidget {
  const HomeCategoryTabs({
    required this.selectedIndex,
    required this.onChanged,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  static const _tabs = [
    (icon: LucideIcons.bookOpen, label: 'Sổ tay môn học'),
    (icon: LucideIcons.gamepad2, label: 'Game'),
    (icon: LucideIcons.timer, label: 'Chuyên tâm'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.mdLg),
        decoration: BoxDecoration(
          color: AppColors.card.withValues(alpha: 0.8),
          borderRadius: AppBorders.borderRadiusXl,
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
          boxShadow: AppShadows.tab,
        ),
        child: Row(
          children: List.generate(_tabs.length, (index) {
            final tab = _tabs[index];
            final isSelected = selectedIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(AppSpacing.smMd),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: AppBorders.borderRadiusLg,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        tab.icon,
                        size: 18,
                        color: isSelected
                            ? AppColors.primaryForeground
                            : AppColors.mutedForeground,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        tab.label,
                        style: AppTypography.buttonMedium.copyWith(
                          color: isSelected
                              ? AppColors.primaryForeground
                              : AppColors.mutedForeground,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
