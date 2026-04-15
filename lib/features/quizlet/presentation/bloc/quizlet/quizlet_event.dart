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
