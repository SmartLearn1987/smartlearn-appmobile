import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/theme.dart';
import '../../domain/entities/quiz_question.dart';

/// Widget chạy trắc nghiệm: hiển thị từng câu hỏi một với các lựa chọn,
/// phản hồi đúng/sai, giải thích, và tổng kết cuối cùng.
class QuizRunnerWidget extends StatefulWidget {
  const QuizRunnerWidget({super.key, required this.questions});

  final List<QuizQuestion> questions;

  @override
  State<QuizRunnerWidget> createState() => _QuizRunnerWidgetState();
}

class _QuizRunnerWidgetState extends State<QuizRunnerWidget> {
  int _currentIndex = 0;
  int? _selectedOptionIndex;
  bool _isChecked = false;
  int _correctCount = 0;
  bool _quizCompleted = false;
  // Tracks which question indices have already been counted as correct,
  // preventing double-counting if _checkAnswer is called more than once.
  final Set<int> _countedCorrect = {};

  QuizQuestion get _currentQuestion => widget.questions[_currentIndex];
  int get _totalQuestions => widget.questions.length;

  static const _optionLabels = ['A', 'B', 'C', 'D'];

  void _selectOption(int index) {
    if (_isChecked) return;
    setState(() => _selectedOptionIndex = index);
  }

  void _checkAnswer() {
    if (_selectedOptionIndex == null || _isChecked) return;
    setState(() {
      _isChecked = true;
      final isCorrect = _selectedOptionIndex == _currentQuestion.correctIndex;
      if (isCorrect && !_countedCorrect.contains(_currentIndex)) {
        _correctCount++;
        _countedCorrect.add(_currentIndex);
      }
    });
  }

  void _retryQuestion() {
    setState(() {
      _selectedOptionIndex = null;
      _isChecked = false;
    });
  }

  void _goToNextQuestion() {
    if (_currentIndex < _totalQuestions - 1) {
      setState(() {
        _currentIndex++;
        _selectedOptionIndex = null;
        _isChecked = false;
      });
    } else {
      setState(() => _quizCompleted = true);
    }
  }

  void _restartQuiz() {
    setState(() {
      _currentIndex = 0;
      _selectedOptionIndex = null;
      _isChecked = false;
      _correctCount = 0;
      _countedCorrect.clear();
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
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

            // Explanation (shown after checking)
            if (_isChecked &&
                _currentQuestion.explanation != null &&
                _currentQuestion.explanation!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              _buildExplanation(),
            ],

            // Action button
            if (_selectedOptionIndex != null) ...[
              const SizedBox(height: AppSpacing.md),
              _buildActionButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCounter() {
    return Row(
      spacing: AppSpacing.sm,
      children: [
        Expanded(
          child: LinearProgressIndicator(
            minHeight: 12,
            value: _currentIndex + 1 / _totalQuestions,
            color: AppColors.primary,
            borderRadius: AppBorders.borderRadiusFull,
            backgroundColor: AppColors.gray100,
          ),
        ),
        Text(
          '${_currentIndex + 1} / $_totalQuestions',
          style: AppTypography.labelSmall.bold.copyWith(
            color: AppColors.mutedForeground,
          ),
        ),
      ],
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
          hasAnswered: _isChecked,
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
          const Icon(LucideIcons.lightbulb, size: 18, color: AppColors.accent),
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

  Widget _buildActionButton() {
    // Not checked yet — show "Kiểm tra"
    if (!_isChecked) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _checkAnswer,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.primaryForeground,
            textStyle: AppTypography.buttonMedium,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.smMd),
            shape: RoundedRectangleBorder(
              borderRadius: AppBorders.borderRadiusSm,
            ),
          ),
          icon: const Icon(LucideIcons.check, size: 18),
          label: const Text('Kiểm tra đáp án'),
        ),
      );
    }

    final isCorrect = _selectedOptionIndex == _currentQuestion.correctIndex;
    final isLastQuestion = _currentIndex >= _totalQuestions - 1;

    // Correct — show "Câu tiếp theo" or "Xem kết quả"
    if (isCorrect) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _goToNextQuestion,
          label: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: AppSpacing.xs,
            children: [
              Text(isLastQuestion ? 'Xem kết quả' : 'Tiếp tục'),
              Icon(LucideIcons.arrowRight, size: 18),
            ],
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: AppColors.successForeground,
            textStyle: AppTypography.buttonMedium,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.smMd),
            shape: RoundedRectangleBorder(
              borderRadius: AppBorders.borderRadiusSm,
            ),
          ),
        ),
      );
    }

    // Wrong — show "Thử lại"
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _retryQuestion,
        icon: const Icon(LucideIcons.refreshCw, size: 18),
        label: const Text('Thử lại'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.destructive,
          backgroundColor: AppColors.destructiveForeground,
          side: BorderSide(
            color: AppColors.destructive,
            width: AppBorders.widthThin,
          ),
          textStyle: AppTypography.buttonMedium,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.smMd),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorders.borderRadiusSm,
          ),
        ),
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
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: isGood
                    ? AppColors.success.withValues(alpha: 0.08)
                    : AppColors.primary.withValues(alpha: 0.08),
                borderRadius: AppBorders.borderRadiusFull,
              ),
              child: Center(
                child: Text(
                  isGood ? "🎉" : "🎯",
                  style: TextStyle(fontSize: 48),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Hoàn thành bài tập!'.toUpperCase(),
              textAlign: TextAlign.center,
              style: AppTypography.text2Xl.bold.copyWith(
                color: AppColors.foreground,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Bạn đã nỗ lực rất tuyệt vời rồi.',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              spacing: AppSpacing.mdLg,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 100,
                  width: 120,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.emerald50,
                    borderRadius: AppBorders.borderRadiusXl,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: AppSpacing.sm,
                    children: [
                      Text(
                        'Chính xác'.toUpperCase(),
                        style: AppTypography.textXs.bold.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        '$_correctCount/$_totalQuestions',
                        style: AppTypography.text3Xl.bold.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 100,
                  width: 120,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.blue50,
                    borderRadius: AppBorders.borderRadiusXl,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: AppSpacing.sm,
                    children: [
                      Text(
                        'Tỉ lệ'.toUpperCase(),
                        style: AppTypography.textXs.copyWith(
                          color: AppColors.blue600,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '$percentage%',
                        style: AppTypography.text3Xl.copyWith(
                          color: AppColors.blue600,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton.icon(
              onPressed: _restartQuiz,
              icon: const Icon(LucideIcons.rotateCcw, size: 18),
              label: const Text('Làm lại từ đầu'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gray100,
                foregroundColor: AppColors.foreground,
                textStyle: AppTypography.buttonMedium,
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.smMd,
                  horizontal: AppSpacing.xl,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: AppBorders.borderRadiusSm,
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
      return isSelected ? AppColors.primaryLight : AppColors.card;
    }
    if (isCorrect) return AppColors.success.withValues(alpha: 0.08);
    if (isSelected) return AppColors.destructive.withValues(alpha: 0.08);
    return AppColors.card;
  }

  Color get _borderColor {
    if (!hasAnswered) {
      return isSelected ? AppColors.primary : AppColors.border;
    }
    if (isCorrect) return AppColors.success;
    if (isSelected) return AppColors.destructive;
    return AppColors.border;
  }

  Color get _labelBackgroundColor {
    if (!hasAnswered) {
      return isSelected ? AppColors.primary : AppColors.muted;
    }
    if (isCorrect) return AppColors.success;
    if (isSelected) return AppColors.destructive;
    return AppColors.muted;
  }

  Color get _labelTextColor {
    if (!hasAnswered) {
      return isSelected ? AppColors.primaryForeground : AppColors.foreground;
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
