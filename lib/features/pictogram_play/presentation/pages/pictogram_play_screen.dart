import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../home/domain/entities/pictogram_entity.dart';
import '../bloc/pictogram_play_bloc.dart';
import '../widgets/game_result_view.dart';
import '../widgets/game_timer_display.dart';
import '../widgets/question_view.dart';

/// Main screen for the Pictogram game play.
///
/// Receives [questions] and [timeInMinutes] from the route extra data,
/// provides [PictogramPlayBloc] to the widget tree, and orchestrates
/// the game flow between [QuestionView] and [GameResultView].
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
        ..add(StartGame(
          questions: questions,
          timeInMinutes: timeInMinutes,
        )),
      child: const _PictogramPlayView(),
    );
  }
}

class _PictogramPlayView extends StatefulWidget {
  const _PictogramPlayView();

  @override
  State<_PictogramPlayView> createState() => _PictogramPlayViewState();
}

class _PictogramPlayViewState extends State<_PictogramPlayView> {
  Timer? _autoAdvanceTimer;

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PictogramPlayBloc, PictogramPlayState>(
      listenWhen: (previous, current) {
        if (current is! PictogramPlayInProgress) return false;
        if (previous is! PictogramPlayInProgress) return false;
        return previous.lastAnswerResult != current.lastAnswerResult;
      },
      listener: (context, state) {
        if (state is PictogramPlayInProgress &&
            state.lastAnswerResult == AnswerResult.correct) {
          _autoAdvanceTimer?.cancel();
          _autoAdvanceTimer = Timer(const Duration(seconds: 1), () {
            if (context.mounted) {
              context.read<PictogramPlayBloc>().add(const NextQuestion());
            }
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () => context.go('/'),
          ),
          title: BlocBuilder<PictogramPlayBloc, PictogramPlayState>(
            buildWhen: (previous, current) =>
                current is PictogramPlayInProgress,
            builder: (context, state) {
              if (state is PictogramPlayInProgress) {
                return GameTimerDisplay(
                  remainingSeconds: state.remainingSeconds,
                );
              }
              return const SizedBox.shrink();
            },
          ),
          centerTitle: true,
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.foreground,
          elevation: 0,
        ),
        backgroundColor: AppColors.background,
        body: BlocBuilder<PictogramPlayBloc, PictogramPlayState>(
          builder: (context, state) => switch (state) {
            PictogramPlayInProgress() => QuestionView(
                question: state.questions[state.currentIndex],
                currentIndex: state.currentIndex,
                totalQuestions: state.questions.length,
                lastAnswerResult: state.lastAnswerResult,
                onSubmit: (text) => context
                    .read<PictogramPlayBloc>()
                    .add(SubmitAnswer(answer: text)),
                onSkip: () => context
                    .read<PictogramPlayBloc>()
                    .add(const SkipQuestion()),
                onNext: () => context
                    .read<PictogramPlayBloc>()
                    .add(const NextQuestion()),
              ),
            PictogramPlayFinished() => GameResultView(
                correctCount: state.correctCount,
                totalQuestions: state.totalQuestions,
                elapsedSeconds: state.elapsedSeconds,
                onPlayAgain: () => context.go('/'),
                onGoHome: () => context.go('/'),
              ),
            _ => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
          },
        ),
      ),
    );
  }
}
