import 'package:flutter/material.dart';

import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_button_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/pictogram_play_bloc.dart';

/// Displays the game result after all questions are answered or time runs out.
///
/// Shows the score (correct/total), elapsed time in MM:SS format,
/// and provides "Chơi lại" (Play Again) and "Về trang chủ" (Go Home) buttons.
class GameResultView extends StatelessWidget {
  const GameResultView({
    required this.correctCount,
    required this.totalQuestions,
    required this.elapsedSeconds,
    required this.onPlayAgain,
    required this.onGoHome,
    super.key,
  });

  final int correctCount;
  final int totalQuestions;
  final int elapsedSeconds;
  final VoidCallback onPlayAgain;
  final VoidCallback onGoHome;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Trophy icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: AppBorders.borderRadiusFull,
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Title
            Text(
              'Kết quả',
              style: AppTypography.h2.copyWith(color: AppColors.foreground),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Score
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: AppBorders.borderRadiusMd,
                border: Border.all(
                  color: AppColors.border,
                  width: AppBorders.widthThin,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Số câu đúng',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '$correctCount/$totalQuestions',
                    style: AppTypography.h1.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Divider(
                    color: AppColors.border,
                    height: AppBorders.widthThin,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Thời gian hoàn thành',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    formatTime(elapsedSeconds),
                    style: AppTypography.h3.copyWith(
                      color: AppColors.foreground,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Play Again button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPlayAgain,
                style: AppButtonStyles.primary,
                child: Text(
                  'Chơi lại',
                  style: AppTypography.buttonLarge,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.smMd),

            // Go Home button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onGoHome,
                style: AppButtonStyles.outline,
                child: Text(
                  'Về trang chủ',
                  style: AppTypography.buttonLarge,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
