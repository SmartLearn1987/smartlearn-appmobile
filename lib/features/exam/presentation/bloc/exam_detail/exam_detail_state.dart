part of 'exam_detail_bloc.dart';

sealed class ExamDetailState extends Equatable {
  const ExamDetailState();

  @override
  List<Object?> get props => [];
}

final class ExamDetailInitial extends ExamDetailState {
  const ExamDetailInitial();
}

final class ExamDetailLoading extends ExamDetailState {
  const ExamDetailLoading();
}

final class ExamDetailLoaded extends ExamDetailState {
  final ExamDetailEntity detail;

  const ExamDetailLoaded({required this.detail});

  @override
  List<Object?> get props => [detail];
}

final class ExamDetailError extends ExamDetailState {
  final String message;

  const ExamDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}
