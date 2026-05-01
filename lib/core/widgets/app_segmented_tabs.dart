import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Visual variant for [AppSegmentedTabs].
///
/// - [muted]: default white pill on muted background.
/// - [primary]: primary-colored pill on light primary background, white text.
enum AppSegmentedTabsVariant { muted, primary }

/// Reusable segmented tab bar with animated sliding pill indicator.
///
/// The selected tab is highlighted by a white pill that slides smoothly
/// between positions using [AnimatedPositioned]. Text color and weight
/// also animate via [AnimatedDefaultTextStyle].
///
/// Usage:
/// ```dart
/// AppSegmentedTabs(
///   tabs: const ['Tab A', 'Tab B'],
///   selectedIndex: _index,
///   onTap: (i) => setState(() => _index = i),
/// )
///
/// // Primary variant:
/// AppSegmentedTabs(
///   tabs: const ['Tab A', 'Tab B'],
///   selectedIndex: _index,
///   onTap: (i) => setState(() => _index = i),
///   variant: AppSegmentedTabsVariant.primary,
/// )
/// ```
class AppSegmentedTabs extends StatelessWidget {
  const AppSegmentedTabs({
    required this.tabs,
    required this.selectedIndex,
    required this.onTap,
    this.height = 40,
    this.variant = AppSegmentedTabsVariant.muted,
    super.key,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final double height;
  final AppSegmentedTabsVariant variant;

  static const _padding = AppSpacing.xs;
  static const _duration = Duration(milliseconds: 250);
  static const _curve = Curves.easeInOut;

  @override
  Widget build(BuildContext context) {
    final isPrimary = variant == AppSegmentedTabsVariant.primary;

    final trackColor = AppColors.muted;

    final pillColor = isPrimary ? AppColors.primary : AppColors.card;

    final selectedTextColor = isPrimary
        ? AppColors.primaryForeground
        : AppColors.foreground;

    final unselectedTextColor = AppColors.mutedForeground;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: AppBorders.borderRadiusMd,
      ),
      padding: const EdgeInsets.all(_padding),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabCount = tabs.length;
          final totalWidth = constraints.maxWidth;
          final tabWidth = totalWidth / tabCount;
          final pillLeft = selectedIndex * tabWidth;

          return SizedBox(
            height: height,
            child: Stack(
              children: [
                // ── Animated sliding pill ──
                AnimatedPositioned(
                  duration: _duration,
                  curve: _curve,
                  left: pillLeft,
                  top: 0,
                  bottom: 0,
                  width: tabWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      color: pillColor,
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      boxShadow: isPrimary ? null : AppShadows.tabActive,
                    ),
                  ),
                ),
                // ── Tab labels ──
                Row(
                  children: List.generate(tabCount, (index) {
                    final isSelected = selectedIndex == index;
                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onTap(index),
                        child: SizedBox(
                          height: height,
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: _duration,
                              curve: _curve,
                              style: AppTypography.buttonSmall.bold.copyWith(
                                fontSize: 13,
                                color: isSelected
                                    ? selectedTextColor
                                    : unselectedTextColor,
                              ),
                              child: Text(tabs[index]),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
