import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/lesson_entity.dart';
import '../../../domain/entities/lesson_image.dart';
import '../../../domain/usecases/create_lesson_use_case.dart';
import '../../../domain/usecases/delete_lesson_image_use_case.dart';
import '../../../domain/usecases/delete_lesson_use_case.dart';
import '../../../domain/usecases/get_lesson_progress_use_case.dart';
import '../../../domain/usecases/get_lessons_use_case.dart';
import '../../../domain/usecases/params/create_lesson_params.dart';
import '../../../domain/usecases/params/delete_image_params.dart';
import '../../../domain/usecases/params/update_lesson_params.dart';
import '../../../domain/usecases/params/update_quiz_flashcards_params.dart';
import '../../../domain/usecases/params/upload_images_params.dart';
import '../../../domain/usecases/update_lesson_use_case.dart';
import '../../../domain/usecases/update_quiz_flashcards_use_case.dart';
import '../../../domain/usecases/upload_lesson_images_use_case.dart';

part 'lessons_list_event.dart';
part 'lessons_list_state.dart';

@injectable
class LessonsListBloc extends Bloc<LessonsListEvent, LessonsListState> {
  final GetLessonsUseCase _getLessons;
  final GetLessonProgressUseCase _getLessonProgress;
  final DeleteLessonUseCase _deleteLesson;
  final CreateLessonUseCase _createLesson;
  final UpdateLessonUseCase _updateLesson;
  final UpdateQuizFlashcardsUseCase _updateQuizFlashcards;
  final UploadLessonImagesUseCase _uploadLessonImages;
  final DeleteLessonImageUseCase _deleteLessonImage;

  String _curriculumId = '';
  String _studentId = '';

  LessonsListBloc(
    this._getLessons,
    this._getLessonProgress,
    this._deleteLesson,
    this._createLesson,
    this._updateLesson,
    this._updateQuizFlashcards,
    this._uploadLessonImages,
    this._deleteLessonImage,
  ) : super(const LessonsListInitial()) {
    on<LessonsLoadRequested>(_onLoadRequested);
    on<LessonDeleteRequested>(_onDeleteRequested);
    on<LessonsRefreshRequested>(_onRefreshRequested);
    on<LessonCreateRequested>(_onCreateRequested);
    on<LessonUpdateRequested>(_onUpdateRequested);
    on<LessonImagesUploadRequested>(_onImagesUploadRequested);
    on<LessonImageDeleteRequested>(_onImageDeleteRequested);
  }

  Future<void> _onLoadRequested(
    LessonsLoadRequested event,
    Emitter<LessonsListState> emit,
  ) async {
    _curriculumId = event.curriculumId;
    _studentId = event.studentId;
    emit(const LessonsListLoading());
    await _loadData(emit);
  }

  Future<void> _onRefreshRequested(
    LessonsRefreshRequested event,
    Emitter<LessonsListState> emit,
  ) async {
    emit(const LessonsListLoading());
    await _loadData(emit);
  }

  Future<void> _onDeleteRequested(
    LessonDeleteRequested event,
    Emitter<LessonsListState> emit,
  ) async {
    final result = await _deleteLesson(event.lessonId);
    result.fold(
      (failure) => emit(LessonDeleteFailure(message: failure.message)),
      (_) {
        emit(const LessonDeleteSuccess());
        add(const LessonsRefreshRequested());
      },
    );
  }

  Future<void> _onCreateRequested(
    LessonCreateRequested event,
    Emitter<LessonsListState> emit,
  ) async {
    emit(const LessonsListLoading());

    // Step 1: Create the lesson
    final createResult = await _createLesson(
      CreateLessonParams(data: event.lessonData),
    );

    await createResult.fold(
      (failure) async {
        emit(LessonSaveFailure(message: failure.message));
      },
      (lesson) async {
        // Step 2: Update quiz/flashcards
        final quizResult = await _updateQuizFlashcards(
          UpdateQuizFlashcardsParams(
            lessonId: lesson.id,
            data: event.quizFlashcardsData,
          ),
        );

        final quizFailed = quizResult.isLeft();
        if (quizFailed) {
          emit(const LessonSaveFailure(
            message: 'Không thể lưu bài học. Vui lòng thử lại.',
          ));
          return;
        }

        // Step 3: Upload images if any
        if (event.images.isNotEmpty) {
          final uploadResult = await _uploadLessonImages(
            UploadImagesParams(
              lessonId: lesson.id,
              images: event.images,
            ),
          );

          final uploadFailed = uploadResult.isLeft();
          if (uploadFailed) {
            emit(const LessonSaveFailure(
              message: 'Không thể lưu bài học. Vui lòng thử lại.',
            ));
            return;
          }
        }

        emit(const LessonSaveSuccess());
        add(const LessonsRefreshRequested());
      },
    );
  }

  Future<void> _onUpdateRequested(
    LessonUpdateRequested event,
    Emitter<LessonsListState> emit,
  ) async {
    emit(const LessonsListLoading());

    // Step 1: Update the lesson
    final updateResult = await _updateLesson(
      UpdateLessonParams(id: event.lessonId, data: event.lessonData),
    );

    await updateResult.fold(
      (failure) async {
        emit(LessonSaveFailure(message: failure.message));
      },
      (lesson) async {
        // Step 2: Update quiz/flashcards
        final quizResult = await _updateQuizFlashcards(
          UpdateQuizFlashcardsParams(
            lessonId: lesson.id,
            data: event.quizFlashcardsData,
          ),
        );

        final quizFailed = quizResult.isLeft();
        if (quizFailed) {
          emit(const LessonSaveFailure(
            message: 'Không thể lưu bài học. Vui lòng thử lại.',
          ));
          return;
        }

        emit(const LessonSaveSuccess());
        add(const LessonsRefreshRequested());
      },
    );
  }

  Future<void> _onImagesUploadRequested(
    LessonImagesUploadRequested event,
    Emitter<LessonsListState> emit,
  ) async {
    emit(const LessonImagesUploading());
    final result = await _uploadLessonImages(
      UploadImagesParams(lessonId: event.lessonId, images: event.images),
    );
    result.fold(
      (failure) => emit(LessonImagesUploadFailure(message: failure.message)),
      (images) => emit(LessonImagesUploadSuccess(images: images)),
    );
  }

  Future<void> _onImageDeleteRequested(
    LessonImageDeleteRequested event,
    Emitter<LessonsListState> emit,
  ) async {
    final result = await _deleteLessonImage(
      DeleteImageParams(lessonId: event.lessonId, imageId: event.imageId),
    );
    result.fold(
      (failure) => emit(LessonImageDeleteFailure(message: failure.message)),
      (_) => emit(LessonImageDeleteSuccess(imageId: event.imageId)),
    );
  }

  Future<void> _loadData(Emitter<LessonsListState> emit) async {
    final lessonsResult = await _getLessons(_curriculumId);
    final progressResult = await _getLessonProgress(_studentId);

    lessonsResult.fold(
      (failure) => emit(LessonsListError(message: failure.message)),
      (lessons) {
        final progressMap = <String, bool>{};
        progressResult.fold(
          (_) {},
          (progressList) {
            for (final progress in progressList) {
              progressMap[progress.lessonId] = progress.completed;
            }
          },
        );

        emit(LessonsListLoaded(
          lessons: lessons,
          progressMap: progressMap,
        ));
      },
    );
  }
}
