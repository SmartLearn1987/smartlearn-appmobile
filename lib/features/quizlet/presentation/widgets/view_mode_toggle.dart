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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.8),
        borderRadius: AppBorders.borderRadiusXl,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        boxShadow: AppShadows.tab,
      ),
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final tab = _tabs[index];
          final isActive = value == tab.mode;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(tab.mode),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(AppSpacing.smMd),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : Colors.transparent,
                  borderRadius: AppBorders.borderRadiusLg,
                ),
                child: Text(
                  tab.label,
                  textAlign: TextAlign.center,
                  style: AppTypography.buttonMedium.copyWith(
                    color: isActive
                        ? AppColors.primaryForeground
                        : AppColors.mutedForeground,
                    fontWeight: FontWeight.w700,
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
