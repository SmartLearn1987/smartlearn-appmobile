import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_button_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../router/route_names.dart';
import '../bloc/nnc_play_bloc.dart';

/// Displays the game result after the Nhanh Như Chớp game ends.
///
/// Shows title "KẾT QUẢ PHẢN XẠ", score summary ("Chính xác: X/Y",
/// "Tỉ lệ: Z%"), a detailed list of each question with user answer,
/// correct answer when wrong, explanation when available, and navigation
/// buttons ("Trang chủ" and "Chơi lại").
///
/// Reads state from [NNCPlayBloc] via [BlocBuilder] and only renders
/// when state is [NNCPlayFinished].
class NNCGameResultView extends StatelessWidget {
  const NNCGameResultView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NNCPlayBloc, NNCPlayState>(
      builder: (context, state) {
        if (state is! NNCPlayFinished) {
          return const SizedBox.shrink();
        }

        final percentage = calculatePercentage(
          state.correctCount,
          state.totalQuestions,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              // ─── Trophy Icon ───
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

              // ─── Title ───
              Text(
                'KẾT QUẢ PHẢN XẠ',
                style: AppTypography.h2.copyWith(color: AppColors.foreground),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ─── Score Card ───
              _buildScoreCard(state, percentage),
              const SizedBox(height: AppSpacing.lg),

              // ─── Detail List ───
              _buildDetailList(state),
              const SizedBox(height: AppSpacing.xl),

              // ─── Action Buttons ───
              _buildActionButtons(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScoreCard(NNCPlayFinished state, double percentage) {
    return Container(
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
            'Chính xác: ${state.correctCount}/${state.totalQuestions}',
            style: AppTypography.h3.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Tỉ lệ: ${percentage.toStringAsFixed(0)}%',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailList(NNCPlayFinished state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chi tiết',
          style: AppTypography.h4.copyWith(color: AppColors.foreground),
        ),
        const SizedBox(height: AppSpacing.smMd),
        ...List.generate(state.totalQuestions, (index) {
          return _buildQuestionDetail(state, index);
        }),
      ],
    );
  }

  Widget _buildQuestionDetail(NNCPlayFinished state, int index) {
    final question = state.questions[index];
    final userAnswerIndex = state.userAnswers[index];
    final isAnswered = userAnswerIndex != -1;
    final isCorrect =
        isAnswered && userAnswerIndex == question.correctIndex;

    final indicatorColor =
        isCorrect ? AppColors.success : AppColors.destructive;
    final bgColor = isCorrect
        ? AppColors.success.withValues(alpha: 0.05)
        : AppColors.destructive.withValues(alpha: 0.05);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isAnswered ? bgColor : AppColors.card,
        borderRadius: AppBorders.borderRadiusMd,
        border: Border.all(
          color: isAnswered
              ? indicatorColor.withValues(alpha: 0.3)
              : AppColors.border,
          width: AppBorders.widthThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question number + indicator
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isAnswered
                      ? indicatorColor.withValues(alpha: 0.15)
                      : AppColors.muted,
                  borderRadius: AppBorders.borderRadiusFull,
                ),
                child: Text(
                  '${index + 1}',
                  style: AppTypography.labelSmall.copyWith(
                    color: isAnswered
                        ? indicatorColor
                        : AppColors.mutedForeground,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (isAnswered)
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: indicatorColor,
                  size: 20,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Question content
          Text(
            question.question,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // User answer
          if (isAnswered) ...[
            Text(
              'BẠN CHỌN',
              style: AppTypography.caption.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              question.options[userAnswerIndex],
              style: AppTypography.labelMedium.copyWith(
                color: indicatorColor,
              ),
            ),
          ] else ...[
            Text(
              '(Bỏ trống)',
              style: AppTypography.caption.copyWith(
                color: AppColors.mutedForeground,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          // Correct answer (shown only when wrong or unanswered)
          if (!isCorrect) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'ĐÁP ÁN',
              style: AppTypography.caption.copyWith(
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              question.options[question.correctIndex],
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.success,
              ),
            ),
          ],

          // Explanation (if available)
          if (question.explanation != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                left: AppSpacing.smMd,
                top: AppSpacing.sm,
                bottom: AppSpacing.sm,
              ),
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: AppColors.primary,
                    width: AppBorders.widthThick,
                  ),
                ),
              ),
              child: Text(
                question.explanation!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.mutedForeground,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // "Chơi lại" button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.go(RoutePaths.home),
            style: AppButtonStyles.primary,
            child: Text(
              'Chơi lại',
              style: AppTypography.buttonLarge,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.smMd),

        // "Trang chủ" button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => context.go(RoutePaths.home),
            style: AppButtonStyles.outline,
            child: Text(
              'Trang chủ',
              style: AppTypography.buttonLarge,
            ),
          ),
        ),
      ],
    );
  }
}
