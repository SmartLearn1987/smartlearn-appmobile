import 'package:flutter/material.dart';
import 'package:smart_learn/core/theme/app_borders.dart';
import 'package:smart_learn/core/theme/app_colors.dart';
import 'package:smart_learn/core/theme/app_shadows.dart';
import 'package:smart_learn/core/theme/app_spacing.dart';
import 'package:smart_learn/core/theme/app_typography.dart';

/// Reusable segmented tab bar matching the design's muted-bg pill style.
/// Used in Lesson Detail (Nội dung / Trắc nghiệm / Flashcard / Tóm tắt).
class AppSegmentedTabs extends StatelessWidget {
  const AppSegmentedTabs({
    required this.tabs,
    required this.selectedIndex,
    required this.onTap,
    super.key,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: AppBorders.borderRadiusMd,
      ),
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = selectedIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.card : Colors.transparent,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  boxShadow: isSelected ? AppShadows.tabActive : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  tabs[index],
                  style: AppTypography.buttonSmall.copyWith(
                    fontSize: 13,
                    color: isSelected
                        ? AppColors.foreground
                        : AppColors.mutedForeground,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
