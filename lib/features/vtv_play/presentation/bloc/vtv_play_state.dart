part of 'vtv_play_bloc.dart';

sealed class VTVPlayState extends Equatable {
  const VTVPlayState();

  @override
  List<Object?> get props => [];
}

final class VTVPlayInitial extends VTVPlayState {
  const VTVPlayInitial();
}

final class VTVPlayInProgress extends VTVPlayState {
  final List<VTVQuestionEntity> questions;
  final int currentIndex;
  final int remainingSeconds;
  final bool isHintVisible;

  /// Per-question user answers. Key = question index, Value = typed answer.
  final Map<int, String> userAnswers;

  /// Per-question answer statuses. Key = question index, Value = status.
  final Map<int, AnswerStatus> answerStatuses;

  /// Kết quả kiểm tra gần nhất (cho feedback UI).
  final AnswerStatus? lastCheckResult;

  const VTVPlayInProgress({
    required this.questions,
    required this.currentIndex,
    required this.remainingSeconds,
    required this.isHintVisible,
    this.userAnswers = const {},
    this.answerStatuses = const {},
    this.lastCheckResult,
  });

  @override
  List<Object?> get props => [
        questions,
        currentIndex,
        remainingSeconds,
        isHintVisible,
        userAnswers,
        answerStatuses,
        lastCheckResult,
      ];
}

final class VTVPlayFinished extends VTVPlayState {
  final List<VTVQuestionEntity> questions;
  final Map<int, String> userAnswers;
  final Map<int, AnswerStatus> answerStatuses;
  final int correctCount;
  final int totalQuestions;
  final int elapsedSeconds;

  const VTVPlayFinished({
    required this.questions,
    required this.userAnswers,
    required this.answerStatuses,
    required this.correctCount,
    required this.totalQuestions,
    required this.elapsedSeconds,
  });

  @override
  List<Object?> get props => [
        questions,
        userAnswers,
        answerStatuses,
        correctCount,
        totalQuestions,
        elapsedSeconds,
      ];
}
