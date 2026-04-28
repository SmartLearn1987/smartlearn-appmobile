import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/theme.dart';
import '../../../../router/route_names.dart';
import '../../domain/entities/exam_question_result.dart';
import '../utils/time_formatter.dart';

class ExamResultPage extends StatelessWidget {
  const ExamResultPage({required this.resultData, super.key});

  final Map<String, dynamic> resultData;

  @override
  Widget build(BuildContext context) {
    final examTitle = (resultData['examTitle'] as String?)?.trim();
    final correctCount = resultData['correctCount'] as int;
    final totalCount = resultData['totalCount'] as int;
    final scorePercent = resultData['scorePercent'] as double;
    final timeTaken = resultData['timeTaken'] as int;
    final questionResults =
        resultData['questionResults'] as List<ExamQuestionResult>;
    final errorMessage = resultData['errorMessage'] as String?;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.mdLg,
                  AppSpacing.mdLg,
                  AppSpacing.mdLg,
                  AppSpacing.sm,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: AppBorders.borderRadiusXl,
                      ),
                      child: Icon(
                        LucideIcons.trophy,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.mdLg),
                    Text(
                      'Kết quả bài làm',
                      style: AppTypography.h1.copyWith(
                        color: AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.mdLg),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Bạn đã hoàn thành bài thi ',
                            style: AppTypography.textLg.copyWith(
                              color: AppColors.mutedForeground,
                            ),
                          ),
                          TextSpan(
                            text:
                                '"${(examTitle?.isNotEmpty ?? false) ? examTitle : 'Bài trắc nghiệm'}"',
                            style: AppTypography.textLg.bold.copyWith(
                              color: AppColors.mutedForeground,
                            ),
                          ),
                          TextSpan(
                            text:
                                '. Hãy cùng xem lại chi tiết bài làm dưới đây nhé!',
                            style: AppTypography.textLg.copyWith(
                              color: AppColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.mdLg),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.muted.withValues(alpha: 0.45),
                        borderRadius: AppBorders.borderRadiusFull,
                        border: Border.all(
                          color: AppColors.border.withValues(alpha: 0.7),
                        ),
                      ),
                      child: TabBar(
                        dividerColor: Colors.transparent,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: AppBorders.borderRadiusFull,
                        ),
                        labelColor: AppColors.foreground,
                        unselectedLabelColor: AppColors.mutedForeground,
                        labelStyle: AppTypography.buttonMedium,
                        tabs: const [
                          Tab(text: 'Thông tin chung'),
                          Tab(text: 'Chi tiết câu hỏi'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.mdLg,
                        AppSpacing.mdLg,
                        AppSpacing.mdLg,
                        AppSpacing.mdLg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _HeaderSection(
                            correctCount: correctCount,
                            totalCount: totalCount,
                            scorePercent: scorePercent,
                            timeTaken: timeTaken,
                          ),
                          const SizedBox(height: AppSpacing.mdLg),
                          if (errorMessage != null) ...[
                            _ErrorBanner(),
                            const SizedBox(height: AppSpacing.mdLg),
                          ],
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
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.mdLg,
                        AppSpacing.mdLg,
                        AppSpacing.mdLg,
                        AppSpacing.mdLg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ...questionResults.asMap().entries.map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.sm,
                              ),
                              child: _QuestionResultCard(
                                questionNumber: entry.key + 1,
                                result: entry.value,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
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
                  ],
                ),
              ),
            ],
          ),
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
    final scoreText = '${scorePercent.round()}%';
    final answerText = '$correctCount/$totalCount';
    final timeText = formatTime(timeTaken);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StatCard(
          title: 'ĐIỂM SỐ',
          value: scoreText,
          valueColor: AppColors.primary,
          borderColor: AppColors.primary.withValues(alpha: 0.22),
        ),
        const SizedBox(height: AppSpacing.md),
        _StatCard(title: 'CÂU TRẢ LỜI', value: answerText),
        const SizedBox(height: AppSpacing.md),
        _StatCard(title: 'THỜI GIAN', value: timeText),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    this.valueColor = AppColors.foreground,
    this.borderColor,
  });

  final String title;
  final String value;
  final Color valueColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.mdLg,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppBorders.borderRadiusXl,
        border: Border.all(
          color: borderColor ?? AppColors.border.withValues(alpha: 0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF111827).withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: AppTypography.caption.copyWith(
              color: AppColors.mutedForeground,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: AppSpacing.smMd),
          Text(
            value,
            style: AppTypography.text3Xl.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ],
      ),
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
  const _QuestionResultCard({
    required this.questionNumber,
    required this.result,
  });

  final int questionNumber;
  final ExamQuestionResult result;

  @override
  Widget build(BuildContext context) {
    final isTextual =
        result.questionType == 'text' || result.questionType == 'ordering';
    final isMultiple = result.questionType == 'multiple';
    final questionTitle = result.questionType == 'ordering'
        ? 'Sắp xếp lại theo thứ tự đúng của câu.'
        : result.questionContent;
    final isCorrect = result.isCorrect;
    final borderColor = isCorrect
        ? AppColors.success.withValues(alpha: 0.28)
        : AppColors.destructive.withValues(alpha: 0.2);
    final badgeBg = isCorrect
        ? AppColors.success.withValues(alpha: 0.12)
        : AppColors.destructive.withValues(alpha: 0.08);
    final badgeFg = isCorrect ? AppColors.success : AppColors.destructive;
    final statusText = isCorrect ? 'CHÍNH XÁC' : 'CẦN XEM LẠI';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.mdLg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppBorders.borderRadiusXl,
        border: Border.all(
          color: borderColor,
          width: AppBorders.widthThin,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF111827).withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: badgeBg,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$questionNumber',
                  style: AppTypography.textLg.bold.copyWith(color: badgeFg),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: AppBorders.borderRadiusFull,
                ),
                child: Text(
                  statusText,
                  style: AppTypography.caption.bold.copyWith(
                    color: badgeFg,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            questionTitle,
            style: AppTypography.h4.bold.copyWith(color: AppColors.foreground),
          ),
          const SizedBox(height: AppSpacing.md),
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
