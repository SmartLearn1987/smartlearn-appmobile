part of 'subject_detail_bloc.dart';

sealed class SubjectDetailEvent extends Equatable {
  const SubjectDetailEvent();

  @override
  List<Object?> get props => [];
}

final class SubjectDetailLoadRequested extends SubjectDetailEvent {
  final String subjectId;

  const SubjectDetailLoadRequested({required this.subjectId});

  @override
  List<Object?> get props => [subjectId];
}

final class CurriculumDeleteRequested extends SubjectDetailEvent {
  final String curriculumId;

  const CurriculumDeleteRequested({required this.curriculumId});

  @override
  List<Object?> get props => [curriculumId];
}

final class SubjectDetailRefreshRequested extends SubjectDetailEvent {
  const SubjectDetailRefreshRequested();
}
