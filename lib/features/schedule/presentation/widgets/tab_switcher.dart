import 'package:flutter/material.dart';

import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class TabSwitcher extends StatelessWidget {
  const TabSwitcher({
    required this.selectedIndex,
    required this.onTabChanged,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  static const _tabs = [
    _TabData(label: 'Thời khóa biểu', icon: Icons.calendar_today),
    _TabData(label: 'Nhiệm vụ', icon: Icons.check_box_outlined),
    _TabData(label: 'Ghi chú', icon: Icons.sticky_note_2_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppBorders.borderRadiusLg,
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs + AppSpacing.xxs),
        child: Row(
          children: List.generate(_tabs.length, (index) {
            final tab = _tabs[index];
            final isSelected = index == selectedIndex;

            return Expanded(
              child: GestureDetector(
                onTap: () => onTabChanged(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm,
                    horizontal: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.card : Colors.transparent,
                    borderRadius: AppBorders.borderRadiusSm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        tab.icon,
                        size: 16,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.mutedForeground,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Flexible(
                        child: Text(
                          tab.label,
                          style: AppTypography.labelSmall.copyWith(
                            color: isSelected
                                ? AppColors.foreground
                                : AppColors.mutedForeground,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
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

class _TabData {
  const _TabData({required this.label, required this.icon});

  final String label;
  final IconData icon;
}
