import 'package:flutter/material.dart';

import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class StepIndicator extends StatelessWidget {
  const StepIndicator({required this.currentStep, super.key});

  final int currentStep;

  static const _steps = ['1. Cấu hình', '2. Xem trước'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_steps.length, (index) {
        final isActive = index == currentStep;
        return Padding(
          padding: EdgeInsets.only(
            right: index < _steps.length - 1 ? AppSpacing.sm : 0,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.muted,
              borderRadius: AppBorders.borderRadiusFull,
            ),
            child: Text(
              _steps[index],
              style: AppTypography.labelSmall.copyWith(
                color: isActive
                    ? AppColors.primaryForeground
                    : AppColors.mutedForeground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }),
    );
  }
}
