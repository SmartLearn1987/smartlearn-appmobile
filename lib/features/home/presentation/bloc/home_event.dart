part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeLoadSubjects extends HomeEvent {
  const HomeLoadSubjects();
}

/// Dispatched after successfully saving user-subjects to reload the list.
class HomeRefreshSubjects extends HomeEvent {
  const HomeRefreshSubjects();
}
