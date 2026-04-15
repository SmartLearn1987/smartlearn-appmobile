part of 'quizlet_detail_bloc.dart';

sealed class QuizletDetailEvent extends Equatable {
  const QuizletDetailEvent();

  @override
  List<Object?> get props => [];
}

final class LoadQuizletDetail extends QuizletDetailEvent {
  const LoadQuizletDetail({required this.quizletId});

  final String quizletId;

  @override
  List<Object?> get props => [quizletId];
}

final class FlipCard extends QuizletDetailEvent {
  const FlipCard();
}

final class NextCard extends QuizletDetailEvent {
  const NextCard();
}

final class PreviousCard extends QuizletDetailEvent {
  const PreviousCard();
}
