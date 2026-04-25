part of 'lesson_detail_bloc.dart';

sealed class LessonDetailState extends Equatable {
  const LessonDetailState();

  @override
  List<Object?> get props => [];
}

final class LessonDetailInitial extends LessonDetailState {
  const LessonDetailInitial();
}

final class LessonDetailLoading extends LessonDetailState {
  const LessonDetailLoading();
}

final class LessonDetailLoaded extends LessonDetailState {
  final LessonEntity lesson;
  final List<LessonImage> images;
  final bool isCompleted;

  const LessonDetailLoaded({
    required this.lesson,
    required this.images,
    required this.isCompleted,
  });

  @override
  List<Object?> get props => [lesson, images, isCompleted];
}

final class LessonDetailError extends LessonDetailState {
  final String message;

  const LessonDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}

final class LessonProgressUpdateSuccess extends LessonDetailState {
  final bool isCompleted;

  const LessonProgressUpdateSuccess({required this.isCompleted});

  @override
  List<Object?> get props => [isCompleted];
}

final class LessonProgressUpdateFailure extends LessonDetailState {
  final String message;

  const LessonProgressUpdateFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
