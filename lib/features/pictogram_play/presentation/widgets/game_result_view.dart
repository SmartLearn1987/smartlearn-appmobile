import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_cached_image.dart';
import '../../../home/domain/entities/pictogram_entity.dart';
import '../bloc/pictogram_play_bloc.dart';

class GameResultView extends StatelessWidget {
  const GameResultView({
    required this.correctCount,
    required this.totalQuestions,
    required this.elapsedSeconds,
    required this.questions,
    required this.answeredQuestions,
    required this.onPlayAgain,
    required this.onGoHome,
    super.key,
  });

  final int correctCount;
  final int totalQuestions;
  final int elapsedSeconds;
  final List<PictogramEntity> questions;
  final Map<int, AnswerResult> answeredQuestions;
  final VoidCallback onPlayAgain;
  final VoidCallback onGoHome;

  @override
  Widget build(BuildContext context) {
    final percentage = totalQuestions > 0
        ? (correctCount / totalQuestions * 100).round()
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
                  value: '$correctCount/$totalQuestions',
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
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // ── Question list ──
                  ...List.generate(questions.length, (i) {
                    final q = questions[i];
                    final result = answeredQuestions[i];
                    final isCorrect = result == AnswerResult.correct;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isCorrect
                              ? AppColors.success.withValues(alpha: 0.05)
                              : AppColors.destructive.withValues(alpha: 0.05),
                          borderRadius: AppBorders.borderRadiusLg,
                          border: Border.all(
                            color: !isCorrect
                                ? AppColors.destructive.withValues(alpha: 0.3)
                                : AppColors.success.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.smMd),
                          child: Row(
                            children: [
                              // Thumbnail
                              ClipRRect(
                                borderRadius: AppBorders.borderRadiusSm,
                                child: AppCachedImage(
                                  imageUrl: q.imageUrl,
                                  width: 72,
                                  height: 72,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.smMd),

                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'CÂU ${i + 1}',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: AppColors.mutedForeground,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xxs),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Đáp án: ',
                                            style: AppTypography.bodySmall
                                                .copyWith(
                                                  color:
                                                      AppColors.mutedForeground,
                                                ),
                                          ),
                                          TextSpan(
                                            text: q.answer.toUpperCase(),
                                            style: AppTypography.labelMedium
                                                .copyWith(
                                                  color: isCorrect
                                                      ? AppColors.success
                                                      : AppColors.destructive,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Result icon
                              Icon(
                                isCorrect
                                    ? LucideIcons.checkCircle
                                    : LucideIcons.x,
                                size: 20,
                                color: isCorrect
                                    ? AppColors.success
                                    : AppColors.destructive,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onGoHome,
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
                  onPressed: onPlayAgain,
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
