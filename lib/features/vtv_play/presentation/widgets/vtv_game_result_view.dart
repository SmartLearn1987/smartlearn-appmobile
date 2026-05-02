import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/theme.dart';
import '../bloc/answer_status.dart';
import '../bloc/vtv_play_bloc.dart';

/// Displays the game result after the Vua Tiếng Việt game ends.
///
/// Shows trophy + score summary (CHÍNH XÁC, TỈ LỆ) and a detailed list of
/// each question with the correct answer and the user's typed answer.
/// Provides "Về trang chủ" and "Chơi lại" actions.
class VTVGameResultView extends StatelessWidget {
  const VTVGameResultView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VTVPlayBloc, VTVPlayState>(
      builder: (context, state) {
        if (state is! VTVPlayFinished) {
          return const SizedBox.shrink();
        }

        final percentage = state.totalQuestions > 0
            ? (state.correctCount / state.totalQuestions * 100).round()
            : 0;

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              // ── Trophy ──
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: AppBorders.borderRadiusFull,
                ),
                child: const Icon(
                  LucideIcons.trophy,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Title ──
              Text(
                'KẾT QUẢ LƯỢT CHƠI',
                style: AppTypography.h3.copyWith(
                  color: AppColors.foreground,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Stats row ──
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'CHÍNH XÁC',
                      value: '${state.correctCount}/${state.totalQuestions}',
                      valueColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _StatCard(
                      label: 'TỈ LỆ',
                      value: '$percentage%',
                      valueColor: AppColors.blue600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Question list ──
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: List.generate(state.totalQuestions, (i) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _QuestionResultTile(
                          index: i,
                          question: state.questions[i].question,
                          correctAnswer: state.questions[i].answer,
                          userAnswer: state.userAnswers[i] ?? '',
                          status:
                              state.answerStatuses[i] ??
                              AnswerStatus.unanswered,
                        ),
                      );
                    }),
                  ),
                ),
              ),

              // ── Action buttons ──
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => context.pop(),
                      icon: const Icon(LucideIcons.home, size: 18),
                      label: const Text('Về trang chủ'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.foreground,
                        side: const BorderSide(color: AppColors.border),
                        shape: AppBorders.shapeSm,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.smMd,
                        ),
                        textStyle: AppTypography.buttonMedium,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          context.read<VTVPlayBloc>().add(const RestartGame()),
                      icon: const Icon(LucideIcons.refreshCcw, size: 18),
                      label: const Text('Chơi lại'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.primaryForeground,
                        shape: AppBorders.shapeSm,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.smMd,
                        ),
                        textStyle: AppTypography.buttonMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.smMd,
      ),
      decoration: BoxDecoration(
        color: valueColor.withValues(alpha: 0.1),
        borderRadius: AppBorders.borderRadiusMd,
        border: Border.all(color: valueColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.h3.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionResultTile extends StatelessWidget {
  const _QuestionResultTile({
    required this.index,
    required this.question,
    required this.correctAnswer,
    required this.userAnswer,
    required this.status,
  });

  final int index;
  final String question;
  final String correctAnswer;
  final String userAnswer;
  final AnswerStatus status;

  @override
  Widget build(BuildContext context) {
    final isCorrect = status == AnswerStatus.checkedCorrect;
    final isChecked =
        status == AnswerStatus.checkedCorrect ||
        status == AnswerStatus.checkedIncorrect;
    final accent = isCorrect ? AppColors.success : AppColors.destructive;

    return Container(
      decoration: BoxDecoration(
        color: isChecked
            ? accent.withValues(alpha: 0.05)
            : AppColors.muted.withValues(alpha: 0.4),
        borderRadius: AppBorders.borderRadiusLg,
        border: Border.all(
          color: isChecked ? accent.withValues(alpha: 0.3) : AppColors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.smMd),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CÂU ${index + 1}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.mutedForeground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    question,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.foreground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Đáp án: ',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.mutedForeground,
                          ),
                        ),
                        TextSpan(
                          text: correctAnswer.toUpperCase(),
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isChecked && !isCorrect) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Bạn chọn: ',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.mutedForeground,
                            ),
                          ),
                          TextSpan(
                            text: userAnswer.isEmpty ? '—' : userAnswer,
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.destructive,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (!isChecked) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Chưa trả lời',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.mutedForeground,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.smMd),
            Icon(
              isChecked
                  ? (isCorrect ? LucideIcons.checkCircle : LucideIcons.x)
                  : LucideIcons.minusCircle,
              size: 20,
              color: isChecked ? accent : AppColors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}
