import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class CurriculumGroupHeader extends StatelessWidget {
  const CurriculumGroupHeader({
    required this.label,
    required this.count,
    super.key,
  });

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
      child: Row(
        children: [
          const Text(
            '●',
            style: TextStyle(color: AppColors.primary, fontSize: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '$label - $count GIÁO TRÌNH',
              style: AppTypography.labelMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
