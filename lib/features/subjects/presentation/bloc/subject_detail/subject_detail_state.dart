part of 'subject_detail_bloc.dart';

sealed class SubjectDetailState extends Equatable {
  const SubjectDetailState();

  @override
  List<Object?> get props => [];
}

final class SubjectDetailInitial extends SubjectDetailState {
  const SubjectDetailInitial();
}

final class SubjectDetailLoading extends SubjectDetailState {
  const SubjectDetailLoading();
}

final class SubjectDetailLoaded extends SubjectDetailState {
  final SubjectEntity subject;
  final Map<String, List<CurriculumEntity>> groupedCurricula;

  const SubjectDetailLoaded({
    required this.subject,
    required this.groupedCurricula,
  });

  @override
  List<Object?> get props => [subject, groupedCurricula];
}

final class SubjectDetailError extends SubjectDetailState {
  final String message;

  const SubjectDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}

final class CurriculumDeleteSuccess extends SubjectDetailState {
  const CurriculumDeleteSuccess();
}

final class CurriculumDeleteFailure extends SubjectDetailState {
  final String message;

  const CurriculumDeleteFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
