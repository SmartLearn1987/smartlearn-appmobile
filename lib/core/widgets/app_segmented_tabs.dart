import 'package:flutter/material.dart';
import 'package:smart_learn/core/theme/app_borders.dart';
import 'package:smart_learn/core/theme/app_colors.dart';
import 'package:smart_learn/core/theme/app_shadows.dart';
import 'package:smart_learn/core/theme/app_spacing.dart';
import 'package:smart_learn/core/theme/app_typography.dart';

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
/// ```
class AppSegmentedTabs extends StatelessWidget {
  const AppSegmentedTabs({
    required this.tabs,
    required this.selectedIndex,
    required this.onTap,
    this.height = 40,
    super.key,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  /// Height of the tab bar (excluding outer padding).
  final double height;

  static const _padding = AppSpacing.xs;
  static const _duration = Duration(milliseconds: 250);
  static const _curve = Curves.easeInOut;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.muted,
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
                      color: AppColors.card,
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      boxShadow: AppShadows.tabActive,
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
                              style: AppTypography.buttonSmall.copyWith(
                                fontSize: 13,
                                color: isSelected
                                    ? AppColors.foreground
                                    : AppColors.mutedForeground,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
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
