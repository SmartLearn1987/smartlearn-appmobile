import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../home/domain/entities/pictogram_entity.dart';
import '../../../../router/route_names.dart';
import '../bloc/pictogram_play_bloc.dart';
import '../widgets/game_result_view.dart';
import '../widgets/question_view.dart';

class PictogramPlayScreen extends StatelessWidget {
  const PictogramPlayScreen({
    required this.questions,
    required this.timeInMinutes,
    super.key,
  });

  final List<PictogramEntity> questions;
  final int timeInMinutes;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PictogramPlayBloc()
        ..add(StartGame(questions: questions, timeInMinutes: timeInMinutes)),
      child: const _PictogramPlayView(),
    );
  }
}

class _PictogramPlayView extends StatelessWidget {
  const _PictogramPlayView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go(RoutePaths.home)),
      ),
      backgroundColor: AppColors.background,
      body: BlocBuilder<PictogramPlayBloc, PictogramPlayState>(
        builder: (context, state) => switch (state) {
          PictogramPlayInProgress() => QuestionView(
            question: state.questions[state.currentIndex],
            currentIndex: state.currentIndex,
            totalQuestions: state.questions.length,
            remainingSeconds: state.remainingSeconds,
            answeredQuestions: state.answeredQuestions,
            lastAnswerResult: state.lastAnswerResult,
            onSubmit: (text) => context.read<PictogramPlayBloc>().add(
              SubmitAnswer(answer: text),
            ),
            onGoTo: (index) => context.read<PictogramPlayBloc>().add(
              GoToQuestion(index: index),
            ),
            onPrevious: () =>
                context.read<PictogramPlayBloc>().add(const PreviousQuestion()),
            onNext: () =>
                context.read<PictogramPlayBloc>().add(const NextQuestion()),
            onEndGame: () =>
                context.read<PictogramPlayBloc>().add(const EndGame()),
          ),
          PictogramPlayFinished() => GameResultView(
            correctCount: state.correctCount,
            totalQuestions: state.totalQuestions,
            elapsedSeconds: state.elapsedSeconds,
            onPlayAgain: () => context.go(RoutePaths.home),
            onGoHome: () => context.go(RoutePaths.home),
          ),
          _ => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        },
      ),
    );
  }
}
