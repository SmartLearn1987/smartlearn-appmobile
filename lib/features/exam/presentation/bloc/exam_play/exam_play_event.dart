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

final class SetAnswer extends ExamPlayEvent {
  final String questionId;
  final dynamic answer;

  const SetAnswer({required this.questionId, required this.answer});

  @override
  List<Object?> get props => [questionId, answer];
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
