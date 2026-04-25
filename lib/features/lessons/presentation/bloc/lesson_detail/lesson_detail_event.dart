part of 'lesson_detail_bloc.dart';

sealed class LessonDetailEvent extends Equatable {
  const LessonDetailEvent();

  @override
  List<Object?> get props => [];
}

final class LessonDetailLoadRequested extends LessonDetailEvent {
  final String lessonId;
  final String studentId;

  const LessonDetailLoadRequested({
    required this.lessonId,
    required this.studentId,
  });

  @override
  List<Object?> get props => [lessonId, studentId];
}

final class LessonProgressToggleRequested extends LessonDetailEvent {
  final String lessonId;
  final String studentId;
  final bool completed;

  const LessonProgressToggleRequested({
    required this.lessonId,
    required this.studentId,
    required this.completed,
  });

  @override
  List<Object?> get props => [lessonId, studentId, completed];
}
