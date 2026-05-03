import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../app/di/injection.dart';
import '../../../../core/theme/theme.dart';
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
                'examTitle': detail.title,
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => _showExitDialog(context),
        ),
        title: Padding(
          padding: const EdgeInsets.only(right: kToolbarHeight),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(LucideIcons.shieldCheck, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.detail.title,
                      style: AppTypography.textBase.bold,
                    ),
                    Text(
                      'Làm bài thi trắc nghiệm',

                      style: AppTypography.text2Xs.semiBold.withColor(
                        AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.mdLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.mdLg,
                  vertical: AppSpacing.sm,
                ),
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.clock,
                            size: 16,
                            color: AppColors.slate400,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: formatTime(
                                    state.timeRemaining,
                                  ).split(':')[0],
                                  style: AppTypography.text2Xl.bold.copyWith(
                                    letterSpacing: 2,
                                  ),
                                ),
                                const WidgetSpan(
                                  child: SizedBox(width: AppSpacing.xs),
                                ),
                                TextSpan(
                                  text: ':',
                                  style: AppTypography.text2Xl.bold.copyWith(
                                    color: AppColors.slate400,
                                  ),
                                ),
                                const WidgetSpan(
                                  child: SizedBox(width: AppSpacing.xs),
                                ),
                                TextSpan(
                                  text: formatTime(
                                    state.timeRemaining,
                                  ).split(':')[1],
                                  style: AppTypography.text2Xl.bold.copyWith(
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(LucideIcons.send),
                      onPressed: () =>
                          context.read<ExamPlayBloc>().add(const SubmitExam()),
                      label: const Text('Nộp bài'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.mdLg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        children: [
                          _QuestionBadge(
                            label: 'CÂU HỎI ${state.currentQuestionIndex + 1}',
                            backgroundColor: AppColors.primaryLight,
                            borderColor: AppColors.primary.withValues(
                              alpha: 0.18,
                            ),
                            textColor: AppColors.primary,
                          ),
                          _QuestionBadge(
                            label: _questionTypeLabel(currentQuestion.type),
                            icon: _questionTypeIcon(currentQuestion.type),
                            backgroundColor: AppColors.accentLight,
                            borderColor: AppColors.accent.withValues(
                              alpha: 0.2,
                            ),
                            textColor: AppColors.accent,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        currentQuestion.content,
                        style: AppTypography.h4.copyWith(
                          color: AppColors.foreground,
                        ),
                      ),
                      if (isOrdering) ...[
                        const SizedBox(height: AppSpacing.sm),
                        _QuestionBadge(
                          label:
                              'Click vào từng từ để chuyển xuống ô trống bên dưới',
                          icon: LucideIcons.alertCircle,
                          backgroundColor: AppColors.gray100,
                          borderColor: AppColors.gray100.withValues(alpha: 0.4),
                          textColor: AppColors.mutedForeground,
                        ),
                      ],
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
                                        final updated =
                                            current.contains(option.id)
                                            ? current
                                                  .where(
                                                    (id) => id != option.id,
                                                  )
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
            ),
          ],
        ),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.chevronLeft),
                      const Text('Câu trước'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  child: Text(
                    '${state.currentQuestionIndex + 1} / $totalQuestions',
                    textAlign: TextAlign.center,
                    style: AppTypography.textSm.bold.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ),
              ),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(isLastQuestion ? 'Nộp bài' : 'Câu tiếp'),
                      Icon(LucideIcons.chevronRight),
                    ],
                  ),
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
          style: TextButton.styleFrom(foregroundColor: AppColors.destructive),
          child: const Text('Thoát'),
        ),
      ],
    ),
  );
}

String _questionTypeLabel(String type) => switch (type) {
  'single' => 'MỘT ĐÁP ÁN',
  'multiple' => 'NHIỀU ĐÁP ÁN',
  'text' => 'TRẢ LỜI VĂN BẢN',
  'ordering' => 'SẮP XẾP CÂU',
  _ => 'TRẮC NGHIỆM',
};

IconData _questionTypeIcon(String type) => switch (type) {
  'single' => LucideIcons.circle,
  'multiple' => LucideIcons.checkSquare,
  'text' => LucideIcons.fileText,
  'ordering' => LucideIcons.gamepad2,
  _ => LucideIcons.helpCircle,
};

class _QuestionBadge extends StatelessWidget {
  const _QuestionBadge({
    required this.label,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    this.icon,
  });

  final String label;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.smMd,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppBorders.borderRadiusFull,
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppSpacing.smMd, color: textColor),
            const SizedBox(width: AppSpacing.xs),
          ],
          Flexible(
            child: Text(
              label,
              style: AppTypography.caption.bold
                  .withColor(textColor)
                  .copyWith(letterSpacing: 0.6),
            ),
          ),
        ],
      ),
    );
  }
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
                  backgroundColor: AppColors.primary,
                  label: Text(
                    word,
                    style: AppTypography.textLg.bold.withColor(
                      AppColors.primaryForeground,
                    ),
                  ),
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
                          backgroundColor: AppColors.primaryLight,
                          side: BorderSide(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            width: AppBorders.widthMedium,
                          ),
                          label: Text(
                            entry.value,
                            style: AppTypography.textLg.bold.withColor(
                              AppColors.primary,
                            ),
                          ),
                          onPressed: () {
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
