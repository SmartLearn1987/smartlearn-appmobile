part of 'cdtn_play_bloc.dart';

enum CheckStatus { correct, incorrect }

sealed class CDTNPlayState extends Equatable {
  const CDTNPlayState();

  @override
  List<Object?> get props => [];
}

final class CDTNPlayInitial extends CDTNPlayState {
  const CDTNPlayInitial();
}

final class CDTNPlayInProgress extends CDTNPlayState {
  final List<ProverbEntity> questions;
  final int currentIndex;
  final int remainingSeconds;
  final List<List<WordItem>> userWordArrangements;
  final CheckStatus? checkStatus;

  const CDTNPlayInProgress({
    required this.questions,
    required this.currentIndex,
    required this.remainingSeconds,
    required this.userWordArrangements,
    this.checkStatus,
  });

  @override
  List<Object?> get props => [
        questions,
        currentIndex,
        remainingSeconds,
        userWordArrangements,
        checkStatus,
      ];
}

final class CDTNPlayFinished extends CDTNPlayState {
  final List<ProverbEntity> questions;
  final List<List<WordItem>> userWordArrangements;
  final int correctCount;
  final int totalQuestions;
  final int elapsedSeconds;

  const CDTNPlayFinished({
    required this.questions,
    required this.userWordArrangements,
    required this.correctCount,
    required this.totalQuestions,
    required this.elapsedSeconds,
  });

  @override
  List<Object?> get props => [
        questions,
        userWordArrangements,
        correctCount,
        totalQuestions,
        elapsedSeconds,
      ];
}
