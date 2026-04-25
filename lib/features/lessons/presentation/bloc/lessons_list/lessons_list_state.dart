part of 'lessons_list_bloc.dart';

sealed class LessonsListState extends Equatable {
  const LessonsListState();

  @override
  List<Object?> get props => [];
}

final class LessonsListInitial extends LessonsListState {
  const LessonsListInitial();
}

final class LessonsListLoading extends LessonsListState {
  const LessonsListLoading();
}

final class LessonsListLoaded extends LessonsListState {
  final List<LessonEntity> lessons;
  final Map<String, bool> progressMap;

  const LessonsListLoaded({
    required this.lessons,
    required this.progressMap,
  });

  @override
  List<Object?> get props => [lessons, progressMap];
}

final class LessonsListError extends LessonsListState {
  final String message;

  const LessonsListError({required this.message});

  @override
  List<Object?> get props => [message];
}

final class LessonDeleteSuccess extends LessonsListState {
  const LessonDeleteSuccess();
}

final class LessonDeleteFailure extends LessonsListState {
  final String message;

  const LessonDeleteFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

final class LessonSaveSuccess extends LessonsListState {
  const LessonSaveSuccess();
}

final class LessonSaveFailure extends LessonsListState {
  final String message;

  const LessonSaveFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

final class LessonImagesUploading extends LessonsListState {
  const LessonImagesUploading();
}

final class LessonImagesUploadSuccess extends LessonsListState {
  final List<LessonImage> images;

  const LessonImagesUploadSuccess({required this.images});

  @override
  List<Object?> get props => [images];
}

final class LessonImagesUploadFailure extends LessonsListState {
  final String message;

  const LessonImagesUploadFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

final class LessonImageDeleteSuccess extends LessonsListState {
  final String imageId;

  const LessonImageDeleteSuccess({required this.imageId});

  @override
  List<Object?> get props => [imageId];
}

final class LessonImageDeleteFailure extends LessonsListState {
  final String message;

  const LessonImageDeleteFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
