part of 'exam_play_bloc.dart';

sealed class ExamPlayState extends Equatable {
  const ExamPlayState();

  @override
  List<Object?> get props => [];
}

final class ExamPlayInitial extends ExamPlayState {
  const ExamPlayInitial();
}

final class ExamPlayInProgress extends ExamPlayState {
  final ExamDetailEntity detail;
  final int currentQuestionIndex;
  final Map<String, String> selectedAnswers;
  final int timeRemaining;
  final int totalTime;

  const ExamPlayInProgress({
    required this.detail,
    required this.currentQuestionIndex,
    required this.selectedAnswers,
    required this.timeRemaining,
    required this.totalTime,
  });

  @override
  List<Object?> get props => [
        detail,
        currentQuestionIndex,
        selectedAnswers,
        timeRemaining,
        totalTime,
      ];
}

final class ExamPlaySubmitting extends ExamPlayState {
  const ExamPlaySubmitting();
}

final class ExamPlayCompleted extends ExamPlayState {
  final int correctCount;
  final int totalCount;
  final double scorePercent;
  final int timeTaken;
  final List<ExamQuestionResult> questionResults;
  final String? errorMessage;

  const ExamPlayCompleted({
    required this.correctCount,
    required this.totalCount,
    required this.scorePercent,
    required this.timeTaken,
    required this.questionResults,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
        correctCount,
        totalCount,
        scorePercent,
        timeTaken,
        questionResults,
        errorMessage,
      ];
}

final class ExamPlayError extends ExamPlayState {
  final String message;

  const ExamPlayError({required this.message});

  @override
  List<Object?> get props => [message];
}
