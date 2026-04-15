part of 'quizlet_detail_bloc.dart';

sealed class QuizletDetailState extends Equatable {
  const QuizletDetailState();

  @override
  List<Object?> get props => [];
}

final class QuizletDetailInitial extends QuizletDetailState {
  const QuizletDetailInitial();
}

final class QuizletDetailLoading extends QuizletDetailState {
  const QuizletDetailLoading();
}

final class QuizletDetailLoaded extends QuizletDetailState {
  final QuizletDetailEntity detail;
  final int currentIndex;
  final bool isFlipped;

  const QuizletDetailLoaded({
    required this.detail,
    required this.currentIndex,
    required this.isFlipped,
  });

  @override
  List<Object?> get props => [detail, currentIndex, isFlipped];
}

final class QuizletDetailError extends QuizletDetailState {
  final String message;

  const QuizletDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}
