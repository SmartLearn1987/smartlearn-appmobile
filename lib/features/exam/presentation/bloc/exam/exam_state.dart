part of 'exam_bloc.dart';

sealed class ExamState extends Equatable {
  const ExamState();

  @override
  List<Object?> get props => [];
}

final class ExamInitial extends ExamState {
  const ExamInitial();
}

final class ExamLoading extends ExamState {
  const ExamLoading();
}

final class ExamLoaded extends ExamState {
  final List<ExamEntity> exams;

  const ExamLoaded({required this.exams});

  @override
  List<Object?> get props => [exams];
}

final class ExamError extends ExamState {
  final String message;

  const ExamError({required this.message});

  @override
  List<Object?> get props => [message];
}
