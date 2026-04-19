part of 'subjects_list_bloc.dart';

sealed class SubjectsListEvent extends Equatable {
  const SubjectsListEvent();

  @override
  List<Object?> get props => [];
}

final class SubjectsListLoadRequested extends SubjectsListEvent {
  const SubjectsListLoadRequested();
}

/// Dispatched after saving user-subjects to reload the list.
final class SubjectsListRefreshRequested extends SubjectsListEvent {
  const SubjectsListRefreshRequested();
}
