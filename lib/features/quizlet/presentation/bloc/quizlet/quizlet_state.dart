part of 'quizlet_bloc.dart';

sealed class QuizletState extends Equatable {
  const QuizletState();

  @override
  List<Object?> get props => [];
}

final class QuizletInitial extends QuizletState {
  const QuizletInitial();
}

final class QuizletLoading extends QuizletState {
  const QuizletLoading();
}

final class QuizletLoaded extends QuizletState {
  final List<QuizletEntity> quizlets;

  const QuizletLoaded({required this.quizlets});

  @override
  List<Object?> get props => [quizlets];
}

final class QuizletError extends QuizletState {
  final String message;

  const QuizletError({required this.message});

  @override
  List<Object?> get props => [message];
}
