import 'package:flutter/material.dart';
import 'package:smart_learn/core/theme/app_borders.dart';
import 'package:smart_learn/core/theme/app_colors.dart';
import 'package:smart_learn/core/theme/app_shadows.dart';
import 'package:smart_learn/core/theme/app_spacing.dart';
import 'package:smart_learn/core/theme/app_typography.dart';
import 'package:smart_learn/features/quizlet/presentation/helpers/quizlet_filter_helper.dart';

class ViewModeToggle extends StatelessWidget {
  static const _tabs = [
    (label: 'Cá nhân', mode: ViewMode.personal),
    (label: 'Cộng đồng', mode: ViewMode.community),
  ];

  final ViewMode value;
  final ValueChanged<ViewMode> onChanged;

  const ViewModeToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final activeIndex = _tabs.indexWhere((tab) => tab.mode == value);

    return Container(
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
                left: tabWidth * activeIndex,
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
                  final isActive = activeIndex == index;
                  return Expanded(
                    child: InkWell(
                      borderRadius: AppBorders.borderRadiusLg,
                      onTap: () => onChanged(tab.mode),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.smMd),
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOut,
                          style: AppTypography.buttonMedium.copyWith(
                            color: isActive
                                ? AppColors.primaryForeground
                                : AppColors.mutedForeground,
                            fontWeight: FontWeight.w700,
                          ),
                          child: Text(tab.label, textAlign: TextAlign.center),
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
    );
  }
}
