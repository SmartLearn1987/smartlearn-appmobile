part of 'nnc_play_bloc.dart';

sealed class NNCPlayEvent extends Equatable {
  const NNCPlayEvent();

  @override
  List<Object?> get props => [];
}

final class StartGame extends NNCPlayEvent {
  final List<NNCQuestionEntity> questions;
  final int timeInMinutes;

  const StartGame({
    required this.questions,
    required this.timeInMinutes,
  });

  @override
  List<Object?> get props => [questions, timeInMinutes];
}

final class SelectAnswer extends NNCPlayEvent {
  final int optionIndex;

  const SelectAnswer({required this.optionIndex});

  @override
  List<Object?> get props => [optionIndex];
}

final class TimerTick extends NNCPlayEvent {
  const TimerTick();
}

final class NextQuestion extends NNCPlayEvent {
  const NextQuestion();
}

final class PreviousQuestion extends NNCPlayEvent {
  const PreviousQuestion();
}

final class GoToQuestion extends NNCPlayEvent {
  final int index;

  const GoToQuestion({required this.index});

  @override
  List<Object?> get props => [index];
}

final class EndGame extends NNCPlayEvent {
  const EndGame();
}

/// Chơi lại với đúng bộ câu hỏi và thời gian ban đầu.
final class RestartGame extends NNCPlayEvent {
  const RestartGame();
}
