import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/hcb_play_bloc.dart';

/// Displays the current card progress as "CÂU X / Y".
class HCBProgressIndicatorWidget extends StatelessWidget {
  const HCBProgressIndicatorWidget({
    required this.currentIndex,
    required this.total,
    super.key,
  });

  final int currentIndex;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Text(
      formatHCBProgress(currentIndex, total),
      style: AppTypography.labelMedium.copyWith(
        color: AppColors.mutedForeground,
        letterSpacing: 0.5,
      ),
    );
  }
}
