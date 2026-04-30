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
    (icon: LucideIcons.bookOpen, label: 'Sổ tay \nmôn học'),
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
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tabWidth = constraints.maxWidth / _tabs.length;
            return Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  left: tabWidth * selectedIndex,
                  top: 0,
                  bottom: 0,
                  width: tabWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: AppBorders.borderRadiusLg,
                    ),
                  ),
                ),
                Row(
                  children: List.generate(_tabs.length, (index) {
                    final tab = _tabs[index];
                    final isSelected = selectedIndex == index;
                    return Expanded(
                      child: InkWell(
                        borderRadius: AppBorders.borderRadiusLg,
                        onTap: () => onChanged(index),
                        child: SizedBox(
                          height: 68,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.smMd,
                              vertical: AppSpacing.sm,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 220),
                                  switchInCurve: Curves.easeOut,
                                  switchOutCurve: Curves.easeIn,
                                  transitionBuilder: (child, animation) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: ScaleTransition(
                                        scale: Tween<double>(
                                          begin: 0.95,
                                          end: 1,
                                        ).animate(animation),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Icon(
                                    tab.icon,
                                    key: ValueKey('${tab.label}-$isSelected'),
                                    size: 18,
                                    color: isSelected
                                        ? AppColors.primaryForeground
                                        : AppColors.mutedForeground,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 220),
                                  curve: Curves.easeOut,
                                  style: AppTypography.buttonSmall.copyWith(
                                    color: isSelected
                                        ? AppColors.primaryForeground
                                        : AppColors.mutedForeground,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    height: 1.2,
                                  ),
                                  child: Text(
                                    tab.label,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
