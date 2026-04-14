part of 'subjects_list_bloc.dart';

sealed class SubjectsListState extends Equatable {
  const SubjectsListState();

  @override
  List<Object?> get props => [];
}

final class SubjectsListInitial extends SubjectsListState {
  const SubjectsListInitial();
}

final class SubjectsListLoading extends SubjectsListState {
  const SubjectsListLoading();
}

final class SubjectsListLoaded extends SubjectsListState {
  final List<SubjectWithCount> subjects;

  const SubjectsListLoaded({required this.subjects});

  @override
  List<Object?> get props => [subjects];
}

final class SubjectsListError extends SubjectsListState {
  final String message;

  const SubjectsListError({required this.message});

  @override
  List<Object?> get props => [message];
}
