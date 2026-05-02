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

/// Chọn một từ ở pool → thêm vào cuối danh sách đáp án.
final class SelectWord extends CDTNPlayEvent {
  final String wordId;

  const SelectWord({required this.wordId});

  @override
  List<Object?> get props => [wordId];
}

/// Bỏ chọn một từ trong đáp án → trả về pool (theo thứ tự gốc).
final class UnselectWord extends CDTNPlayEvent {
  final String wordId;

  const UnselectWord({required this.wordId});

  @override
  List<Object?> get props => [wordId];
}

/// Xoá toàn bộ đáp án của câu hiện tại.
final class ClearArrangement extends CDTNPlayEvent {
  const ClearArrangement();

  @override
  List<Object?> get props => [];
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

/// Chơi lại với đúng bộ câu hỏi và thời gian ban đầu.
final class RestartGame extends CDTNPlayEvent {
  const RestartGame();

  @override
  List<Object?> get props => [];
}
