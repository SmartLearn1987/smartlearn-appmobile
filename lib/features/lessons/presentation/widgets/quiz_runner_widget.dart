import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/quiz_question.dart';

/// Widget chạy trắc nghiệm: hiển thị từng câu hỏi một với các lựa chọn,
/// phản hồi đúng/sai, giải thích, và tổng kết cuối cùng.
class QuizRunnerWidget extends StatefulWidget {
  const QuizRunnerWidget({
    super.key,
    required this.questions,
  });

  final List<QuizQuestion> questions;

  @override
  State<QuizRunnerWidget> createState() => _QuizRunnerWidgetState();
}

class _QuizRunnerWidgetState extends State<QuizRunnerWidget> {
  int _currentIndex = 0;
  int? _selectedOptionIndex;
  bool _hasAnswered = false;
  int _correctCount = 0;
  bool _quizCompleted = false;

  QuizQuestion get _currentQuestion => widget.questions[_currentIndex];
  int get _totalQuestions => widget.questions.length;

  static const _optionLabels = ['A', 'B', 'C', 'D'];

  void _selectOption(int index) {
    if (_hasAnswered) return;

    setState(() {
      _selectedOptionIndex = index;
      _hasAnswered = true;
      if (index == _currentQuestion.correctIndex) {
        _correctCount++;
      }
    });
  }

  void _goToNextQuestion() {
    if (_currentIndex < _totalQuestions - 1) {
      setState(() {
        _currentIndex++;
        _selectedOptionIndex = null;
        _hasAnswered = false;
      });
    } else {
      setState(() {
        _quizCompleted = true;
      });
    }
  }

  void _restartQuiz() {
    setState(() {
      _currentIndex = 0;
      _selectedOptionIndex = null;
      _hasAnswered = false;
      _correctCount = 0;
      _quizCompleted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_quizCompleted) {
      return _buildCompletionSummary();
    }
    return _buildQuestionView();
  }

  Widget _buildQuestionView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question counter
        _buildQuestionCounter(),
        const SizedBox(height: AppSpacing.md),

        // Question text
        _buildQuestionText(),
        const SizedBox(height: AppSpacing.md),

        // Options
        ..._buildOptions(),

        // Explanation (shown after answering)
        if (_hasAnswered && _currentQuestion.explanation != null &&
            _currentQuestion.explanation!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          _buildExplanation(),
        ],

        // Next button (shown after answering)
        if (_hasAnswered) ...[
          const SizedBox(height: AppSpacing.md),
          _buildNextButton(),
        ],
      ],
    );
  }

  Widget _buildQuestionCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.smMd,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.quizLight,
        borderRadius: AppBorders.borderRadiusFull,
      ),
      child: Text(
        'Câu ${_currentIndex + 1}/$_totalQuestions',
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.quiz,
        ),
      ),
    );
  }

  Widget _buildQuestionText() {
    return Text(
      _currentQuestion.question,
      style: AppTypography.h4.copyWith(
        color: AppColors.foreground,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  List<Widget> _buildOptions() {
    final options = _currentQuestion.options;
    final maxOptions = options.length > 4 ? 4 : options.length;

    return List.generate(maxOptions, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: _OptionTile(
          label: _optionLabels[index],
          text: options[index],
          isSelected: _selectedOptionIndex == index,
          isCorrect: index == _currentQuestion.correctIndex,
          hasAnswered: _hasAnswered,
          onTap: () => _selectOption(index),
        ),
      );
    });
  }

  Widget _buildExplanation() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.smMd),
      decoration: BoxDecoration(
        color: AppColors.accentLight,
        borderRadius: AppBorders.borderRadiusSm,
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.3),
          width: AppBorders.widthThin,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            LucideIcons.lightbulb,
            size: 18,
            color: AppColors.accent,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              _currentQuestion.explanation!,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    final isLastQuestion = _currentIndex >= _totalQuestions - 1;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _goToNextQuestion,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.quiz,
          foregroundColor: AppColors.quizForeground,
          textStyle: AppTypography.buttonMedium,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.smMd),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorders.borderRadiusSm,
          ),
        ),
        child: Text(isLastQuestion ? 'Xem kết quả' : 'Câu tiếp theo'),
      ),
    );
  }

  Widget _buildCompletionSummary() {
    final percentage = (_correctCount / _totalQuestions * 100).round();
    final isGood = percentage >= 70;

    return Center(
      child: Container(
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isGood ? LucideIcons.trophy : LucideIcons.target,
              size: 56,
              color: isGood ? AppColors.secondary : AppColors.quiz,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Hoàn thành!',
              style: AppTypography.h3.copyWith(
                color: AppColors.foreground,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Bạn đã trả lời đúng $_correctCount/$_totalQuestions câu',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '$percentage%',
              style: AppTypography.h2.copyWith(
                color: isGood ? AppColors.success : AppColors.quiz,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _restartQuiz,
                icon: const Icon(LucideIcons.refreshCw, size: 18),
                label: const Text('Làm lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.quiz,
                  foregroundColor: AppColors.quizForeground,
                  textStyle: AppTypography.buttonMedium,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.smMd,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppBorders.borderRadiusSm,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.text,
    required this.isSelected,
    required this.isCorrect,
    required this.hasAnswered,
    required this.onTap,
  });

  final String label;
  final String text;
  final bool isSelected;
  final bool isCorrect;
  final bool hasAnswered;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: hasAnswered ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.smMd),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: AppBorders.borderRadiusSm,
          border: Border.all(
            color: _borderColor,
            width: isSelected ? AppBorders.widthThick : AppBorders.widthThin,
          ),
        ),
        child: Row(
          children: [
            // Option label badge (A, B, C, D)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _labelBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  label,
                  style: AppTypography.labelMedium.copyWith(
                    color: _labelTextColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.smMd),

            // Option text
            Expanded(
              child: Text(
                text,
                style: AppTypography.bodyMedium.copyWith(
                  color: _textColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),

            // Result icon (shown after answering)
            if (hasAnswered && (isSelected || isCorrect))
              Icon(
                isCorrect ? LucideIcons.checkCircle2 : LucideIcons.xCircle,
                size: 20,
                color: isCorrect ? AppColors.success : AppColors.destructive,
              ),
          ],
        ),
      ),
    );
  }

  Color get _backgroundColor {
    if (!hasAnswered) {
      return isSelected ? AppColors.quizLight : AppColors.card;
    }
    if (isCorrect) return AppColors.success.withValues(alpha: 0.08);
    if (isSelected) return AppColors.destructive.withValues(alpha: 0.08);
    return AppColors.card;
  }

  Color get _borderColor {
    if (!hasAnswered) {
      return isSelected ? AppColors.quiz : AppColors.border;
    }
    if (isCorrect) return AppColors.success;
    if (isSelected) return AppColors.destructive;
    return AppColors.border;
  }

  Color get _labelBackgroundColor {
    if (!hasAnswered) {
      return isSelected ? AppColors.quiz : AppColors.muted;
    }
    if (isCorrect) return AppColors.success;
    if (isSelected) return AppColors.destructive;
    return AppColors.muted;
  }

  Color get _labelTextColor {
    if (!hasAnswered) {
      return isSelected ? AppColors.quizForeground : AppColors.foreground;
    }
    if (isCorrect) return AppColors.successForeground;
    if (isSelected) return AppColors.destructiveForeground;
    return AppColors.foreground;
  }

  Color get _textColor {
    if (!hasAnswered) return AppColors.foreground;
    if (isCorrect) return AppColors.success;
    if (isSelected) return AppColors.destructive;
    return AppColors.mutedForeground;
  }
}
