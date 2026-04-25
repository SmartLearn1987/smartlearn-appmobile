part of 'quizlet_bloc.dart';

sealed class QuizletEvent extends Equatable {
  const QuizletEvent();

  @override
  List<Object?> get props => [];
}

final class LoadQuizlets extends QuizletEvent {
  const LoadQuizlets();
}

final class RefreshQuizlets extends QuizletEvent {
  const RefreshQuizlets();
}

final class ChangeViewMode extends QuizletEvent {
  final ViewMode viewMode;

  const ChangeViewMode(this.viewMode);

  @override
  List<Object?> get props => [viewMode];
}

final class SearchQuizlets extends QuizletEvent {
  final String query;

  const SearchQuizlets(this.query);

  @override
  List<Object?> get props => [query];
}

final class DeleteQuizlet extends QuizletEvent {
  final String id;

  const DeleteQuizlet(this.id);

  @override
  List<Object?> get props => [id];
}

final class SyncUserContext extends QuizletEvent {
  final String userId;
  final String? educationLevel;

  const SyncUserContext({
    required this.userId,
    required this.educationLevel,
  });

  @override
  List<Object?> get props => [userId, educationLevel];
}
