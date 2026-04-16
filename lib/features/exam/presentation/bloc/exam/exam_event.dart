part of 'exam_bloc.dart';

sealed class ExamEvent extends Equatable {
  const ExamEvent();

  @override
  List<Object?> get props => [];
}

final class LoadExams extends ExamEvent {
  const LoadExams();
}

final class RefreshExams extends ExamEvent {
  const RefreshExams();
}
