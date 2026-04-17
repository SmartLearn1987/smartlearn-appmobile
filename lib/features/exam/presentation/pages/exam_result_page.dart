import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../router/route_names.dart';
import '../../domain/entities/exam_question_result.dart';
import '../utils/time_formatter.dart';

class ExamResultPage extends StatelessWidget {
  const ExamResultPage({required this.resultData, super.key});

  final Map<String, dynamic> resultData;

  @override
  Widget build(BuildContext context) {
    final correctCount = resultData['correctCount'] as int;
    final totalCount = resultData['totalCount'] as int;
    final scorePercent = resultData['scorePercent'] as double;
    final timeTaken = resultData['timeTaken'] as int;
    final questionResults =
        resultData['questionResults'] as List<ExamQuestionResult>;
    final errorMessage = resultData['errorMessage'] as String?;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Kết quả',
          style: AppTypography.h4.copyWith(color: AppColors.foreground),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.mdLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Header Section ───
            _HeaderSection(
              correctCount: correctCount,
              totalCount: totalCount,
              scorePercent: scorePercent,
              timeTaken: timeTaken,
            ),
            const SizedBox(height: AppSpacing.mdLg),

            // ─── Error Banner ───
            if (errorMessage != null) ...[
              _ErrorBanner(),
              const SizedBox(height: AppSpacing.mdLg),
            ],

            // ─── Question Results List ───
            ...questionResults.map(
              (result) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _QuestionResultCard(result: result),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ─── Bottom Button ───
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go(RoutePaths.quizzes),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.primaryForeground,
                  textStyle: AppTypography.buttonLarge,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.smMd,
                  ),
                ),
                child: const Text('Quay về danh sách'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.correctCount,
    required this.totalCount,
    required this.scorePercent,
    required this.timeTaken,
  });

  final int correctCount;
  final int totalCount;
  final double scorePercent;
  final int timeTaken;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$correctCount/$totalCount',
          style: AppTypography.text3Xl.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${scorePercent.toStringAsFixed(1)}% đúng',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.mutedForeground,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Thời gian: ${formatTime(timeTaken)}',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.smMd),
      decoration: BoxDecoration(
        color: AppColors.destructive.withValues(alpha: 0.1),
        borderRadius: AppBorders.borderRadiusSm,
      ),
      child: Text(
        'Không thể lưu kết quả, vui lòng thử lại',
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.destructive,
        ),
      ),
    );
  }
}

class _QuestionResultCard extends StatelessWidget {
  const _QuestionResultCard({required this.result});

  final ExamQuestionResult result;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppBorders.borderRadiusMd,
        border: Border.all(color: AppColors.border, width: AppBorders.widthThin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            result.questionContent,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...result.options.map(
            (option) => _OptionRow(
              content: option.content,
              isCorrectOption: option.id == result.correctOptionId,
              isSelectedWrong: option.id == result.selectedOptionId &&
                  !result.isCorrect,
            ),
          ),
          if (result.selectedOptionId == null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Chưa trả lời',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.content,
    required this.isCorrectOption,
    required this.isSelectedWrong,
  });

  final String content;
  final bool isCorrectOption;
  final bool isSelectedWrong;

  @override
  Widget build(BuildContext context) {
    final Color textColor;
    final IconData? icon;
    final Color? iconColor;

    if (isCorrectOption) {
      textColor = AppColors.success;
      icon = Icons.check_circle;
      iconColor = AppColors.success;
    } else if (isSelectedWrong) {
      textColor = AppColors.destructive;
      icon = Icons.cancel;
      iconColor = AppColors.destructive;
    } else {
      textColor = AppColors.foreground;
      icon = null;
      iconColor = null;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: AppSpacing.xs),
          ],
          Expanded(
            child: Text(
              content,
              style: AppTypography.bodyMedium.copyWith(color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}
