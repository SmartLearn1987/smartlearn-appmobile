import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../app/di/injection.dart';
import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../router/route_names.dart';
import '../../domain/entities/exam_detail_entity.dart';
import '../bloc/exam_play/exam_play_bloc.dart';
import '../utils/time_formatter.dart';

class ExamPlayPage extends StatelessWidget {
  const ExamPlayPage({required this.detail, super.key});

  final ExamDetailEntity detail;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ExamPlayBloc>(
      create: (_) => getIt<ExamPlayBloc>()
        ..add(StartExam(detail: detail, durationInMinutes: detail.duration)),
      child: const _ExamPlayView(),
    );
  }
}

class _ExamPlayView extends StatelessWidget {
  const _ExamPlayView();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _showExitDialog(context);
      },
      child: BlocConsumer<ExamPlayBloc, ExamPlayState>(
        listener: (context, state) {
          if (state is ExamPlayCompleted) {
            final detail = context
                .findAncestorWidgetOfExactType<ExamPlayPage>()!
                .detail;
            context.go(
              RoutePaths.examResult(detail.id),
              extra: {
                'correctCount': state.correctCount,
                'totalCount': state.totalCount,
                'scorePercent': state.scorePercent,
                'timeTaken': state.timeTaken,
                'questionResults': state.questionResults,
                'errorMessage': state.errorMessage,
              },
            );
          }
        },
        builder: (context, state) => switch (state) {
          ExamPlayInProgress() => _InProgressContent(state: state),
          ExamPlaySubmitting() => const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator()),
          ),
          _ => const Scaffold(
            backgroundColor: AppColors.background,
            body: SizedBox.shrink(),
          ),
        },
      ),
    );
  }
}

class _InProgressContent extends StatelessWidget {
  const _InProgressContent({required this.state});

  final ExamPlayInProgress state;

  @override
  Widget build(BuildContext context) {
    final questions = state.detail.questions;
    final currentQuestion = questions[state.currentQuestionIndex];
    final answeredCount = state.selectedAnswers.length;
    final totalQuestions = questions.length;
    final isLastQuestion = state.currentQuestionIndex == totalQuestions - 1;
    final isFirstQuestion = state.currentQuestionIndex == 0;
    final selectedAnswer = state.selectedAnswers[currentQuestion.id];
    final isOrdering = currentQuestion.type == 'ordering';
    final isText = currentQuestion.type == 'text';
    final isMultiple = currentQuestion.type == 'multiple';
    final orderingWords = isOrdering
        ? _buildOrderingWords(
            selectedAnswer,
            currentQuestion.options.isNotEmpty
                ? currentQuestion.options.first.content
                : '',
          )
        : const _OrderingWords(selected: [], available: []);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => _showExitDialog(context),
        ),
        title: Text(
          formatTime(state.timeRemaining),
          style: AppTypography.h4.copyWith(
            color: state.timeRemaining < 60
                ? AppColors.destructive
                : AppColors.foreground,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: totalQuestions > 0 ? answeredCount / totalQuestions : 0,
            backgroundColor: AppColors.muted,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.mdLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Câu ${state.currentQuestionIndex + 1}/$totalQuestions',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    isOrdering
                        ? 'Sắp xếp lại theo đúng thứ tự của câu.'
                        : currentQuestion.content,
                    style: AppTypography.h4.copyWith(
                      color: AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.mdLg),
                  Expanded(
                    child: isOrdering
                        ? _OrderingQuestionView(
                            questionId: currentQuestion.id,
                            selectedWords: orderingWords.selected,
                            availableWords: orderingWords.available,
                          )
                        : isText
                        ? _TextQuestionView(
                            questionId: currentQuestion.id,
                            value: selectedAnswer is String
                                ? selectedAnswer
                                : '',
                          )
                        : ListView.separated(
                            itemCount: currentQuestion.options.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: AppSpacing.sm),
                            itemBuilder: (context, index) {
                              final option = currentQuestion.options[index];
                              final isSelected = isMultiple
                                  ? (selectedAnswer is List &&
                                        selectedAnswer.contains(option.id))
                                  : selectedAnswer == option.id;

                              return GestureDetector(
                                onTap: () {
                                  final bloc = context.read<ExamPlayBloc>();
                                  if (isMultiple) {
                                    final current = (selectedAnswer is List)
                                        ? selectedAnswer.cast<String>()
                                        : <String>[];
                                    final updated = current.contains(option.id)
                                        ? current
                                              .where((id) => id != option.id)
                                              .toList()
                                        : [...current, option.id];
                                    bloc.add(
                                      SetAnswer(
                                        questionId: currentQuestion.id,
                                        answer: updated,
                                      ),
                                    );
                                    return;
                                  }
                                  bloc.add(
                                    SetAnswer(
                                      questionId: currentQuestion.id,
                                      answer: option.id,
                                    ),
                                  );
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: AppSpacing.paddingCard,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primaryLight
                                        : AppColors.card,
                                    borderRadius: AppBorders.borderRadiusMd,
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.border,
                                      width: isSelected
                                          ? AppBorders.widthMedium
                                          : AppBorders.widthThin,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isMultiple
                                            ? (isSelected
                                                  ? LucideIcons.checkSquare
                                                  : LucideIcons.square)
                                            : (isSelected
                                                  ? LucideIcons.checkCircle2
                                                  : LucideIcons.circle),
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.mutedForeground,
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Expanded(
                                        child: Text(
                                          option.content,
                                          style: AppTypography.bodyMedium
                                              .copyWith(
                                                color: AppColors.foreground,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.mdLg,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: isFirstQuestion
                      ? null
                      : () => context.read<ExamPlayBloc>().add(
                          const PreviousQuestion(),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.muted,
                    foregroundColor: AppColors.foreground,
                    disabledBackgroundColor: AppColors.muted.withValues(
                      alpha: 0.5,
                    ),
                    disabledForegroundColor: AppColors.mutedForeground
                        .withValues(alpha: 0.5),
                    textStyle: AppTypography.buttonMedium,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.smMd,
                    ),
                  ),
                  child: const Text('Câu trước'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (isLastQuestion) {
                      context.read<ExamPlayBloc>().add(const SubmitExam());
                    } else {
                      context.read<ExamPlayBloc>().add(const NextQuestion());
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.primaryForeground,
                    textStyle: AppTypography.buttonMedium,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.smMd,
                    ),
                  ),
                  child: Text(isLastQuestion ? 'Nộp bài' : 'Câu tiếp'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showExitDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Xác nhận thoát'),
      content: const Text(
        'Bạn có chắc muốn thoát? Tiến trình làm bài sẽ bị mất.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Tiếp tục làm bài'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            context.go(RoutePaths.quizzes);
          },
          child: const Text('Thoát'),
        ),
      ],
    ),
  );
}

class _TextQuestionView extends StatelessWidget {
  const _TextQuestionView({required this.questionId, required this.value});

  final String questionId;
  final String value;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: TextEditingController(text: value)
        ..selection = TextSelection.collapsed(offset: value.length),
      maxLines: 6,
      onChanged: (text) => context.read<ExamPlayBloc>().add(
        SetAnswer(questionId: questionId, answer: text),
      ),
      decoration: InputDecoration(
        hintText: 'Nhập đáp án của bạn...',
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: AppBorders.borderRadiusMd,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppBorders.borderRadiusMd,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorders.borderRadiusMd,
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: AppBorders.widthMedium,
          ),
        ),
      ),
    );
  }
}

class _OrderingQuestionView extends StatelessWidget {
  const _OrderingQuestionView({
    required this.questionId,
    required this.selectedWords,
    required this.availableWords,
  });

  final String questionId;
  final List<String> selectedWords;
  final List<String> availableWords;

  @override
  Widget build(BuildContext context) {
    void syncAnswer(List<String> updatedSelected) {
      context.read<ExamPlayBloc>().add(
        SetAnswer(questionId: questionId, answer: updatedSelected.join(' ')),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: availableWords
              .map(
                (word) => ActionChip(
                  label: Text(word),
                  onPressed: () => syncAnswer([...selectedWords, word]),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          width: double.infinity,
          padding: AppSpacing.paddingMd,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: AppBorders.borderRadiusMd,
            border: Border.all(
              color: AppColors.border,
              style: BorderStyle.solid,
            ),
          ),
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: selectedWords.isEmpty
                ? [
                    Text(
                      'Chọn từ ở phía trên để sắp xếp câu',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ]
                : selectedWords
                      .asMap()
                      .entries
                      .map(
                        (entry) => InputChip(
                          label: Text(entry.value),
                          onDeleted: () {
                            final updated = [...selectedWords]
                              ..removeAt(entry.key);
                            syncAnswer(updated);
                          },
                        ),
                      )
                      .toList(),
          ),
        ),
      ],
    );
  }
}

class _OrderingWords {
  const _OrderingWords({required this.selected, required this.available});

  final List<String> selected;
  final List<String> available;
}

_OrderingWords _buildOrderingWords(
  dynamic selectedAnswer,
  String sourceSentence,
) {
  final allWords = sourceSentence
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.trim().isNotEmpty)
      .toList();
  final selectedWords = (selectedAnswer is String ? selectedAnswer : '')
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.trim().isNotEmpty)
      .toList();
  final availableWords = [...allWords];
  for (final word in selectedWords) {
    availableWords.remove(word);
  }
  return _OrderingWords(selected: selectedWords, available: availableWords);
}
