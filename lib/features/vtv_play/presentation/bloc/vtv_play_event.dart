part of 'vtv_play_bloc.dart';

sealed class VTVPlayEvent extends Equatable {
  const VTVPlayEvent();

  @override
  List<Object?> get props => [];
}

final class StartGame extends VTVPlayEvent {
  final List<VTVQuestionEntity> questions;
  final int timeInMinutes;

  const StartGame({
    required this.questions,
    required this.timeInMinutes,
  });

  @override
  List<Object?> get props => [questions, timeInMinutes];
}

final class CheckAnswer extends VTVPlayEvent {
  final String answer;

  const CheckAnswer({required this.answer});

  @override
  List<Object?> get props => [answer];
}

final class ToggleHint extends VTVPlayEvent {
  const ToggleHint();
}

final class TimerTick extends VTVPlayEvent {
  const TimerTick();
}

final class NextQuestion extends VTVPlayEvent {
  const NextQuestion();
}

final class PreviousQuestion extends VTVPlayEvent {
  const PreviousQuestion();
}

final class GoToQuestion extends VTVPlayEvent {
  final int index;

  const GoToQuestion({required this.index});

  @override
  List<Object?> get props => [index];
}

final class UpdateAnswer extends VTVPlayEvent {
  final String answer;

  const UpdateAnswer({required this.answer});

  @override
  List<Object?> get props => [answer];
}

final class EndGame extends VTVPlayEvent {
  const EndGame();
}

/// Khởi động lại lượt chơi với cùng bộ câu hỏi và thời gian ban đầu.
final class RestartGame extends VTVPlayEvent {
  const RestartGame();
}
