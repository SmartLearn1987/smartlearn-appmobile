import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

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
    _TabData(label: 'Thời khóa biểu', icon: LucideIcons.calendarDays),
    _TabData(label: 'Nhiệm vụ', icon: LucideIcons.listChecks),
    _TabData(label: 'Ghi chú', icon: LucideIcons.stickyNote),
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
                      color: AppColors.card,
                      borderRadius: AppBorders.borderRadiusSm,
                    ),
                  ),
                ),
                Row(
                  children: List.generate(_tabs.length, (index) {
                    final tab = _tabs[index];
                    final isSelected = index == selectedIndex;

                    return Expanded(
                      child: InkWell(
                        borderRadius: AppBorders.borderRadiusSm,
                        onTap: () => onTabChanged(index),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm,
                            horizontal: AppSpacing.xs,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 220),
                                child: Icon(
                                  tab.icon,
                                  key: ValueKey('${tab.label}-$isSelected'),
                                  size: 16,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.mutedForeground,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Flexible(
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 220),
                                  curve: Curves.easeOut,
                                  style: AppTypography.labelSmall.copyWith(
                                    color: isSelected
                                        ? AppColors.foreground
                                        : AppColors.mutedForeground,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                  child: Text(
                                    tab.label,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                            ],
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

class _TabData {
  const _TabData({required this.label, required this.icon});

  final String label;
  final IconData icon;
}
