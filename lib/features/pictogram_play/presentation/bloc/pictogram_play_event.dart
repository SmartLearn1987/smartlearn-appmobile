part of 'pictogram_play_bloc.dart';

sealed class PictogramPlayEvent extends Equatable {
  const PictogramPlayEvent();

  @override
  List<Object?> get props => [];
}

final class StartGame extends PictogramPlayEvent {
  final List<PictogramEntity> questions;
  final int timeInMinutes;

  const StartGame({
    required this.questions,
    required this.timeInMinutes,
  });

  @override
  List<Object?> get props => [questions, timeInMinutes];
}

final class SubmitAnswer extends PictogramPlayEvent {
  final String answer;

  const SubmitAnswer({required this.answer});

  @override
  List<Object?> get props => [answer];
}

final class SkipQuestion extends PictogramPlayEvent {
  const SkipQuestion();
}

final class TimerTick extends PictogramPlayEvent {
  const TimerTick();
}

final class NextQuestion extends PictogramPlayEvent {
  const NextQuestion();
}

final class EndGame extends PictogramPlayEvent {
  const EndGame();
}

final class EndGameWithResults extends PictogramPlayEvent {
  final Map<int, AnswerResult> answeredQuestions;
  final int correctCount;

  const EndGameWithResults({
    required this.answeredQuestions,
    required this.correctCount,
  });

  @override
  List<Object?> get props => [answeredQuestions, correctCount];
}

final class GoToQuestion extends PictogramPlayEvent {
  final int index;

  const GoToQuestion({required this.index});

  @override
  List<Object?> get props => [index];
}

final class PreviousQuestion extends PictogramPlayEvent {
  const PreviousQuestion();
}
