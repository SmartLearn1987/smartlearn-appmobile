import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Data class representing a single quiz question in the editor.
class EditableQuizQuestion {
  EditableQuizQuestion({
    TextEditingController? questionController,
    List<TextEditingController>? optionControllers,
    this.correctIndex = 0,
    TextEditingController? explanationController,
  })  : questionController =
            questionController ?? TextEditingController(),
        optionControllers = optionControllers ??
            List.generate(4, (_) => TextEditingController()),
        explanationController =
            explanationController ?? TextEditingController();

  final TextEditingController questionController;
  final List<TextEditingController> optionControllers;
  int correctIndex;
  final TextEditingController explanationController;

  void dispose() {
    questionController.dispose();
    for (final c in optionControllers) {
      c.dispose();
    }
    explanationController.dispose();
  }
}

/// Editor widget for managing a list of quiz questions.
///
/// Displays each question with fields for question text, four options (A–D),
/// a correct answer selector, and an optional explanation. Supports adding
/// and removing questions.
///
/// The parent can access the current quiz data via [QuizQuestionEditorState.questions].
class QuizQuestionEditor extends StatefulWidget {
  const QuizQuestionEditor({
    super.key,
    this.initialQuestions = const [],
    this.onChanged,
  });

  /// Initial quiz question data for edit mode.
  /// Each map should contain: question, options (`List<String>`),
  /// correctIndex (int), explanation (String?).
  final List<Map<String, dynamic>> initialQuestions;

  /// Called whenever the quiz question list changes.
  final VoidCallback? onChanged;

  @override
  State<QuizQuestionEditor> createState() => QuizQuestionEditorState();
}

class QuizQuestionEditorState extends State<QuizQuestionEditor> {
  final List<EditableQuizQuestion> _questions = [];

  static const _optionLabels = ['A', 'B', 'C', 'D'];

  @override
  void initState() {
    super.initState();
    for (final q in widget.initialQuestions) {
      final options = (q['options'] as List<dynamic>?)?.cast<String>() ?? [];
      _questions.add(
        EditableQuizQuestion(
          questionController:
              TextEditingController(text: q['question'] as String? ?? ''),
          optionControllers: List.generate(
            4,
            (i) => TextEditingController(
              text: i < options.length ? options[i] : '',
            ),
          ),
          correctIndex: (q['correctIndex'] as int?) ?? 0,
          explanationController:
              TextEditingController(text: q['explanation'] as String? ?? ''),
        ),
      );
    }
  }

  @override
  void dispose() {
    for (final q in _questions) {
      q.dispose();
    }
    super.dispose();
  }

  /// Returns the current list of quiz question data as maps.
  List<Map<String, dynamic>> get questions => _questions
      .map(
        (q) => <String, dynamic>{
          'question': q.questionController.text,
          'options': q.optionControllers.map((c) => c.text).toList(),
          'correctIndex': q.correctIndex,
          'explanation': q.explanationController.text,
        },
      )
      .toList();

  void _addQuestion() {
    setState(() {
      _questions.add(EditableQuizQuestion());
    });
    widget.onChanged?.call();
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions[index].dispose();
      _questions.removeAt(index);
    });
    widget.onChanged?.call();
  }

  void _setCorrectIndex(int questionIndex, int optionIndex) {
    setState(() {
      _questions[questionIndex].correctIndex = optionIndex;
    });
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_questions.isEmpty)
          _buildEmptyState()
        else
          ..._questions.asMap().entries.map(
                (entry) => _buildQuestionCard(entry.key, entry.value),
              ),
        const SizedBox(height: AppSpacing.smMd),
        _buildAddButton(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.mdLg),
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: AppBorders.borderRadiusSm,
        border: Border.all(
          color: AppColors.border,
          width: AppBorders.widthThin,
        ),
      ),
      child: Column(
        children: [
          Icon(
            LucideIcons.helpCircle,
            size: 32,
            color: AppColors.mutedForeground,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Chưa có câu hỏi nào. Nhấn "Thêm câu hỏi" để bắt đầu.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.mutedForeground,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(int index, EditableQuizQuestion question) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppBorders.borderRadiusSm,
          border: Border.all(
            color: AppColors.border,
            width: AppBorders.widthThin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuestionHeader(index),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.smMd,
                0,
                AppSpacing.smMd,
                AppSpacing.smMd,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question text field
                  _buildTextField(
                    controller: question.questionController,
                    hintText: 'Nhập câu hỏi...',
                    maxLines: 2,
                  ),
                  const SizedBox(height: AppSpacing.smMd),
                  // Option fields with correct answer selector
                  ...List.generate(4, (optIndex) {
                    final isCorrect = question.correctIndex == optIndex;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => _setCorrectIndex(index, optIndex),
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isCorrect
                                      ? AppColors.primary
                                      : AppColors.mutedForeground,
                                  width: isCorrect
                                      ? AppBorders.widthMedium
                                      : AppBorders.widthThin,
                                ),
                              ),
                              child: isCorrect
                                  ? Center(
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            _optionLabels[optIndex],
                            style: AppTypography.labelMedium.copyWith(
                              color: isCorrect
                                  ? AppColors.primary
                                  : AppColors.mutedForeground,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: _buildTextField(
                              controller:
                                  question.optionControllers[optIndex],
                              hintText:
                                  'Đáp án ${_optionLabels[optIndex]}',
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: AppSpacing.sm),
                  // Explanation field
                  Text(
                    'Giải thích (tùy chọn)',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _buildTextField(
                    controller: question.explanationController,
                    hintText: 'Nhập giải thích cho đáp án đúng...',
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionHeader(int index) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.smMd,
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.quizLight,
              borderRadius: AppBorders.borderRadiusSm,
            ),
            child: Text(
              'Câu ${index + 1}',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.quiz,
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 32,
            height: 32,
            child: IconButton(
              onPressed: () => _removeQuestion(index),
              icon: const Icon(LucideIcons.trash2, size: 16),
              color: AppColors.destructive,
              padding: EdgeInsets.zero,
              splashRadius: 16,
              tooltip: 'Xóa câu hỏi',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      onChanged: (_) => widget.onChanged?.call(),
      style: AppTypography.bodyMedium.copyWith(color: AppColors.foreground),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.mutedForeground,
        ),
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.smMd,
        ),
        isDense: true,
        border: _inputBorder(AppColors.input),
        enabledBorder: _inputBorder(AppColors.input),
        focusedBorder:
            _inputBorder(AppColors.primary, width: AppBorders.widthMedium),
      ),
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _addQuestion,
        icon: const Icon(LucideIcons.plus, size: 16),
        label: const Text('Thêm câu hỏi'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.quiz,
          textStyle: AppTypography.buttonMedium,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.smMd),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorders.borderRadiusSm,
          ),
          side: BorderSide(
            color: AppColors.quiz.withValues(alpha: 0.3),
            width: AppBorders.widthThin,
          ),
        ),
      ),
    );
  }

  OutlineInputBorder _inputBorder(Color color,
      {double width = AppBorders.widthThin}) {
    return OutlineInputBorder(
      borderRadius: AppBorders.borderRadiusSm,
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
