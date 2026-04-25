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
  final List<QuizletEntity> allQuizlets;
  final List<QuizletEntity> filteredQuizlets;
  final ViewMode viewMode;
  final String searchQuery;

  const QuizletLoaded({
    List<QuizletEntity>? quizlets,
    List<QuizletEntity>? allQuizlets,
    List<QuizletEntity>? filteredQuizlets,
    this.viewMode = ViewMode.community,
    this.searchQuery = '',
  })  : allQuizlets = allQuizlets ?? quizlets ?? const [],
        filteredQuizlets = filteredQuizlets ?? quizlets ?? const [];

  List<QuizletEntity> get quizlets => filteredQuizlets;

  QuizletLoaded copyWith({
    List<QuizletEntity>? allQuizlets,
    List<QuizletEntity>? filteredQuizlets,
    ViewMode? viewMode,
    String? searchQuery,
  }) {
    return QuizletLoaded(
      allQuizlets: allQuizlets ?? this.allQuizlets,
      filteredQuizlets: filteredQuizlets ?? this.filteredQuizlets,
      viewMode: viewMode ?? this.viewMode,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        allQuizlets,
        filteredQuizlets,
        viewMode,
        searchQuery,
      ];
}

final class QuizletError extends QuizletState {
  final String message;

  const QuizletError({required this.message});

  @override
  List<Object?> get props => [message];
}
