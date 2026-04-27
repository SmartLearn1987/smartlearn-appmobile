part of 'exam_bloc.dart';

sealed class ExamEvent extends Equatable {
  const ExamEvent();

  @override
  List<Object?> get props => [];
}

final class LoadExams extends ExamEvent {
  final String tab;
  final String search;

  const LoadExams({required this.tab, this.search = ''});

  @override
  List<Object?> get props => [tab, search];
}

final class RefreshExams extends ExamEvent {
  final String tab;
  final String search;

  const RefreshExams({required this.tab, this.search = ''});

  @override
  List<Object?> get props => [tab, search];
}
