part of 'nnc_play_bloc.dart';

sealed class NNCPlayState extends Equatable {
  const NNCPlayState();

  @override
  List<Object?> get props => [];
}

final class NNCPlayInitial extends NNCPlayState {
  const NNCPlayInitial();
}

final class NNCPlayLoading extends NNCPlayState {
  const NNCPlayLoading();
}

final class NNCPlayInProgress extends NNCPlayState {
  final List<NNCQuestionEntity> questions;
  final int currentIndex;
  final int remainingSeconds;

  /// Per-question user answers. Length == questions.length, -1 = chưa trả lời.
  final List<int> userAnswers;

  const NNCPlayInProgress({
    required this.questions,
    required this.currentIndex,
    required this.remainingSeconds,
    required this.userAnswers,
  });

  @override
  List<Object?> get props =>
      [questions, currentIndex, remainingSeconds, userAnswers];
}

final class NNCPlayFinished extends NNCPlayState {
  final List<NNCQuestionEntity> questions;
  final List<int> userAnswers;
  final int correctCount;
  final int totalQuestions;
  final int elapsedSeconds;

  const NNCPlayFinished({
    required this.questions,
    required this.userAnswers,
    required this.correctCount,
    required this.totalQuestions,
    required this.elapsedSeconds,
  });

  @override
  List<Object?> get props =>
      [questions, userAnswers, correctCount, totalQuestions, elapsedSeconds];
}
