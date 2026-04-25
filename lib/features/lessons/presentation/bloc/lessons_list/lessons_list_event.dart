part of 'lessons_list_bloc.dart';

sealed class LessonsListEvent extends Equatable {
  const LessonsListEvent();

  @override
  List<Object?> get props => [];
}

final class LessonsLoadRequested extends LessonsListEvent {
  final String curriculumId;
  final String studentId;

  const LessonsLoadRequested({
    required this.curriculumId,
    required this.studentId,
  });

  @override
  List<Object?> get props => [curriculumId, studentId];
}

final class LessonDeleteRequested extends LessonsListEvent {
  final String lessonId;

  const LessonDeleteRequested({required this.lessonId});

  @override
  List<Object?> get props => [lessonId];
}

final class LessonsRefreshRequested extends LessonsListEvent {
  const LessonsRefreshRequested();
}

final class LessonCreateRequested extends LessonsListEvent {
  final Map<String, dynamic> lessonData;
  final Map<String, dynamic> quizFlashcardsData;
  final List<File> images;

  const LessonCreateRequested({
    required this.lessonData,
    required this.quizFlashcardsData,
    required this.images,
  });

  @override
  List<Object?> get props => [lessonData, quizFlashcardsData, images];
}

final class LessonUpdateRequested extends LessonsListEvent {
  final String lessonId;
  final Map<String, dynamic> lessonData;
  final Map<String, dynamic> quizFlashcardsData;

  const LessonUpdateRequested({
    required this.lessonId,
    required this.lessonData,
    required this.quizFlashcardsData,
  });

  @override
  List<Object?> get props => [lessonId, lessonData, quizFlashcardsData];
}

final class LessonImagesUploadRequested extends LessonsListEvent {
  final String lessonId;
  final List<File> images;

  const LessonImagesUploadRequested({
    required this.lessonId,
    required this.images,
  });

  @override
  List<Object?> get props => [lessonId, images];
}

final class LessonImageDeleteRequested extends LessonsListEvent {
  final String lessonId;
  final String imageId;

  const LessonImageDeleteRequested({
    required this.lessonId,
    required this.imageId,
  });

  @override
  List<Object?> get props => [lessonId, imageId];
}
