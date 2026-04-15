part of 'pictogram_play_bloc.dart';

enum AnswerResult { correct, incorrect }

sealed class PictogramPlayState extends Equatable {
  const PictogramPlayState();

  @override
  List<Object?> get props => [];
}

final class PictogramPlayInitial extends PictogramPlayState {
  const PictogramPlayInitial();
}

final class PictogramPlayInProgress extends PictogramPlayState {
  final List<PictogramEntity> questions;
  final int currentIndex;
  final int correctCount;
  final int remainingSeconds;
  final AnswerResult? lastAnswerResult;

  const PictogramPlayInProgress({
    required this.questions,
    required this.currentIndex,
    required this.correctCount,
    required this.remainingSeconds,
    this.lastAnswerResult,
  });

  @override
  List<Object?> get props => [
        questions,
        currentIndex,
        correctCount,
        remainingSeconds,
        lastAnswerResult,
      ];
}

final class PictogramPlayFinished extends PictogramPlayState {
  final int correctCount;
  final int totalQuestions;
  final int elapsedSeconds;

  const PictogramPlayFinished({
    required this.correctCount,
    required this.totalQuestions,
    required this.elapsedSeconds,
  });

  @override
  List<Object?> get props => [correctCount, totalQuestions, elapsedSeconds];
}
