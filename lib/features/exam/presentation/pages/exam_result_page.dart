import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

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
        style: AppTypography.bodySmall.copyWith(color: AppColors.destructive),
      ),
    );
  }
}

class _QuestionResultCard extends StatelessWidget {
  const _QuestionResultCard({required this.result});

  final ExamQuestionResult result;

  @override
  Widget build(BuildContext context) {
    final isTextual =
        result.questionType == 'text' || result.questionType == 'ordering';
    final isMultiple = result.questionType == 'multiple';
    final questionTitle = result.questionType == 'ordering'
        ? 'Sắp xếp lại theo thứ tự đúng của câu.'
        : result.questionContent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppBorders.borderRadiusMd,
        border: Border.all(
          color: AppColors.border,
          width: AppBorders.widthThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            questionTitle,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (isTextual)
            _TextualResultView(result: result)
          else ...[
            ...result.options.map(
              (option) => _OptionRow(
                content: option.content,
                isCorrectOption: option.isCorrect,
                isSelected: isMultiple
                    ? result.selectedOptionIds.contains(option.id)
                    : option.id == result.selectedOptionId,
              ),
            ),
            if (result.selectedOptionId == null &&
                result.selectedOptionIds.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  'Chưa trả lời',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _TextualResultView extends StatelessWidget {
  const _TextualResultView({required this.result});

  final ExamQuestionResult result;

  @override
  Widget build(BuildContext context) {
    final selectedText = (result.selectedTextAnswer ?? '').trim();
    final hasSelected = selectedText.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.smMd),
          decoration: BoxDecoration(
            color: AppColors.muted.withValues(alpha: 0.4),
            borderRadius: AppBorders.borderRadiusSm,
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bạn đã trả lời:',
                style: AppTypography.caption.copyWith(
                  color: AppColors.mutedForeground,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                hasSelected ? selectedText : 'Chưa nhập câu trả lời',
                style: AppTypography.bodyMedium.copyWith(
                  color: result.isCorrect
                      ? AppColors.success
                      : AppColors.destructive,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (!result.isCorrect) ...[
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.smMd),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.08),
              borderRadius: AppBorders.borderRadiusSm,
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đáp án đúng:',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  (result.correctTextAnswer ?? '').trim().isEmpty
                      ? 'Không có đáp án mẫu'
                      : result.correctTextAnswer!.trim(),
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.content,
    required this.isCorrectOption,
    required this.isSelected,
  });

  final String content;
  final bool isCorrectOption;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final Color textColor;
    final IconData? icon;
    final Color? iconColor;

    if (isSelected && isCorrectOption) {
      textColor = AppColors.success;
      icon = LucideIcons.checkCircle2;
      iconColor = AppColors.success;
    } else if (isSelected && !isCorrectOption) {
      textColor = AppColors.destructive;
      icon = LucideIcons.xCircle;
      iconColor = AppColors.destructive;
    } else if (!isSelected && isCorrectOption) {
      textColor = AppColors.success;
      icon = LucideIcons.arrowRight;
      iconColor = AppColors.success;
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
