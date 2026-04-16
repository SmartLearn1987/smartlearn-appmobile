part of 'exam_play_bloc.dart';

sealed class ExamPlayEvent extends Equatable {
  const ExamPlayEvent();

  @override
  List<Object?> get props => [];
}

final class StartExam extends ExamPlayEvent {
  final ExamDetailEntity detail;
  final int durationInMinutes;

  const StartExam({required this.detail, required this.durationInMinutes});

  @override
  List<Object?> get props => [detail, durationInMinutes];
}

final class SelectAnswer extends ExamPlayEvent {
  final String questionId;
  final String optionId;

  const SelectAnswer({required this.questionId, required this.optionId});

  @override
  List<Object?> get props => [questionId, optionId];
}

final class NextQuestion extends ExamPlayEvent {
  const NextQuestion();
}

final class PreviousQuestion extends ExamPlayEvent {
  const PreviousQuestion();
}

final class SubmitExam extends ExamPlayEvent {
  const SubmitExam();
}

final class TimerTick extends ExamPlayEvent {
  const TimerTick();
}
