import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injection.dart';
import '../../../../core/theme/app_borders.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
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
        ..add(
          StartExam(detail: detail, durationInMinutes: detail.duration),
        ),
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
              '/exams/${detail.id}/result',
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
    final isLastQuestion =
        state.currentQuestionIndex == totalQuestions - 1;
    final isFirstQuestion = state.currentQuestionIndex == 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
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
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.primary),
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
                    currentQuestion.content,
                    style: AppTypography.h4.copyWith(
                      color: AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.mdLg),
                  Expanded(
                    child: ListView.separated(
                      itemCount: currentQuestion.options.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final option = currentQuestion.options[index];
                        final isSelected =
                            state.selectedAnswers[currentQuestion.id] ==
                                option.id;

                        return GestureDetector(
                          onTap: () =>
                              context.read<ExamPlayBloc>().add(
                                    SelectAnswer(
                                      questionId: currentQuestion.id,
                                      optionId: option.id,
                                    ),
                                  ),
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
                            child: Text(
                              option.content,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.foreground,
                              ),
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
                      : () => context
                          .read<ExamPlayBloc>()
                          .add(const PreviousQuestion()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.muted,
                    foregroundColor: AppColors.foreground,
                    disabledBackgroundColor: AppColors.muted.withValues(
                      alpha: 0.5,
                    ),
                    disabledForegroundColor:
                        AppColors.mutedForeground.withValues(alpha: 0.5),
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
                      context
                          .read<ExamPlayBloc>()
                          .add(const SubmitExam());
                    } else {
                      context
                          .read<ExamPlayBloc>()
                          .add(const NextQuestion());
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
            context.go('/quizzes');
          },
          child: const Text('Thoát'),
        ),
      ],
    ),
  );
}
