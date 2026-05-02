import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/theme.dart';
import '../bloc/nnc_play_bloc.dart';

/// Displays the game result after the Nhanh Như Chớp game ends.
///
/// Style đồng bộ với pictogram/CDTN result view:
///   - Trophy + tiêu đề "KẾT QUẢ LƯỢT CHƠI"
///   - Hai [_StatCard]: "CHÍNH XÁC", "TỈ LỆ"
///   - Danh sách câu (mỗi câu là một [_QuestionResultTile])
///   - Hai nút "Về trang chủ" (outlined) và "Chơi lại" (filled)
class NNCGameResultView extends StatelessWidget {
  const NNCGameResultView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NNCPlayBloc, NNCPlayState>(
      builder: (context, state) {
        if (state is! NNCPlayFinished) {
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
                      final question = state.questions[i];
                      final userAnswerIndex = state.userAnswers[i];
                      final hasAttempt = userAnswerIndex != -1;
                      final isCorrect = hasAttempt &&
                          userAnswerIndex == question.correctIndex;
                      final userAnswer = hasAttempt
                          ? question.options[userAnswerIndex]
                          : '';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _QuestionResultTile(
                          index: i,
                          question: question.question,
                          correctAnswer:
                              question.options[question.correctIndex],
                          userAnswer: userAnswer,
                          explanation: question.explanation,
                          isCorrect: isCorrect,
                          hasAttempt: hasAttempt,
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
                      onPressed: () => context
                          .read<NNCPlayBloc>()
                          .add(const RestartGame()),
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

// ── _StatCard ──────────────────────────────────────────────────────────────

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

// ── _QuestionResultTile ────────────────────────────────────────────────────

class _QuestionResultTile extends StatelessWidget {
  const _QuestionResultTile({
    required this.index,
    required this.question,
    required this.correctAnswer,
    required this.userAnswer,
    required this.explanation,
    required this.isCorrect,
    required this.hasAttempt,
  });

  final int index;
  final String question;
  final String correctAnswer;
  final String userAnswer;
  final String? explanation;
  final bool isCorrect;
  final bool hasAttempt;

  @override
  Widget build(BuildContext context) {
    final accent = isCorrect ? AppColors.success : AppColors.destructive;

    return Container(
      decoration: BoxDecoration(
        color: hasAttempt
            ? accent.withValues(alpha: 0.05)
            : AppColors.muted.withValues(alpha: 0.4),
        borderRadius: AppBorders.borderRadiusLg,
        border: Border.all(
          color: hasAttempt
              ? accent.withValues(alpha: 0.3)
              : AppColors.border,
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
                          text: correctAnswer,
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasAttempt && !isCorrect) ...[
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
                            text: userAnswer,
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
                  if (!hasAttempt) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Chưa trả lời',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.mutedForeground,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  if (explanation != null && explanation!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                        left: AppSpacing.smMd,
                        top: AppSpacing.xs,
                        bottom: AppSpacing.xs,
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
                        explanation!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.mutedForeground,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.smMd),
            Icon(
              hasAttempt
                  ? (isCorrect ? LucideIcons.checkCircle : LucideIcons.x)
                  : LucideIcons.minusCircle,
              size: 20,
              color: hasAttempt ? accent : AppColors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}
