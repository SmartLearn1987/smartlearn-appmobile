import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/pictogram_play_bloc.dart';

/// Displays the remaining game time in MM:SS format.
///
/// Text color changes to [AppColors.destructive] (red) when
/// [remainingSeconds] drops below 30.
class GameTimerDisplay extends StatelessWidget {
  const GameTimerDisplay({required this.remainingSeconds, super.key});

  final int remainingSeconds;

  @override
  Widget build(BuildContext context) {
    final isWarning = remainingSeconds < 30;
    final color = isWarning ? AppColors.destructive : AppColors.foreground;

    return Text(
      formatTime(remainingSeconds),
      style: AppTypography.labelLarge.copyWith(color: color),
    );
  }
}
