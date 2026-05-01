import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/theme.dart';
import '../../../../router/route_names.dart';
import '../bloc/cdtn_play_bloc.dart';

/// Displays the game result after the Ca Dao Tục Ngữ game ends.
///
/// Shows score summary ("Chính xác: X/Y", "Tỉ lệ: Z%"), a detailed list
/// of each question with the user's word arrangement and correct answer,
/// and navigation buttons ("Về trang chủ" and "Chơi lại").
///
/// Reads state from [CDTNPlayBloc] via [BlocBuilder] and only renders
/// when state is [CDTNPlayFinished].
class CDTNGameResultView extends StatelessWidget {
  const CDTNGameResultView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CDTNPlayBloc, CDTNPlayState>(
      builder: (context, state) {
        if (state is! CDTNPlayFinished) {
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
                'Kết quả lượt chơi',
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

  Widget _buildScoreCard(CDTNPlayFinished state, double percentage) {
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

  Widget _buildDetailList(CDTNPlayFinished state) {
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

  Widget _buildQuestionDetail(CDTNPlayFinished state, int index) {
    final question = state.questions[index];
    final userWords = state.userWordArrangements[index];
    final isCorrect = CDTNPlayBloc.checkWordOrder(userWords, question.content);
    final userAnswer =
        userWords.isEmpty ? '(Bỏ trống)' : joinWords(userWords);

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
        color: bgColor,
        borderRadius: AppBorders.borderRadiusMd,
        border: Border.all(
          color: indicatorColor.withValues(alpha: 0.3),
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
                  color: indicatorColor.withValues(alpha: 0.15),
                  borderRadius: AppBorders.borderRadiusFull,
                ),
                child: Text(
                  '${index + 1}',
                  style: AppTypography.labelSmall.copyWith(
                    color: indicatorColor,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Câu ${index + 1}',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.foreground,
                ),
              ),
              const Spacer(),
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: indicatorColor,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // User's word arrangement
          Text(
            userAnswer,
            style: AppTypography.bodyMedium.copyWith(
              color: indicatorColor,
              fontStyle: userWords.isEmpty ? FontStyle.italic : FontStyle.normal,
            ),
          ),

          // Correct answer (shown only when wrong)
          if (!isCorrect) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Đáp án: ${question.content}',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.success,
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

        // "Về trang chủ" button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => context.go(RoutePaths.home),
            style: AppButtonStyles.outline,
            child: Text(
              'Về trang chủ',
              style: AppTypography.buttonLarge,
            ),
          ),
        ),
      ],
    );
  }
}
