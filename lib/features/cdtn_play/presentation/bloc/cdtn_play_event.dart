part of 'cdtn_play_bloc.dart';

sealed class CDTNPlayEvent extends Equatable {
  const CDTNPlayEvent();
}

final class StartGame extends CDTNPlayEvent {
  final List<ProverbEntity> questions;
  final int timeInMinutes;

  const StartGame({required this.questions, required this.timeInMinutes});

  @override
  List<Object?> get props => [questions, timeInMinutes];
}

final class ReorderWords extends CDTNPlayEvent {
  final int oldIndex;
  final int newIndex;

  const ReorderWords({required this.oldIndex, required this.newIndex});

  @override
  List<Object?> get props => [oldIndex, newIndex];
}

final class CheckAnswer extends CDTNPlayEvent {
  const CheckAnswer();

  @override
  List<Object?> get props => [];
}

final class TimerTick extends CDTNPlayEvent {
  const TimerTick();

  @override
  List<Object?> get props => [];
}

final class NextQuestion extends CDTNPlayEvent {
  const NextQuestion();

  @override
  List<Object?> get props => [];
}

final class PreviousQuestion extends CDTNPlayEvent {
  const PreviousQuestion();

  @override
  List<Object?> get props => [];
}

final class GoToQuestion extends CDTNPlayEvent {
  final int index;

  const GoToQuestion({required this.index});

  @override
  List<Object?> get props => [index];
}

final class EndGame extends CDTNPlayEvent {
  const EndGame();

  @override
  List<Object?> get props => [];
}
