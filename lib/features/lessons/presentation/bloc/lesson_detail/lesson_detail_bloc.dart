import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/lesson_entity.dart';
import '../../../domain/entities/lesson_image.dart';
import '../../../domain/usecases/get_lesson_by_id_use_case.dart';
import '../../../domain/usecases/get_lesson_images_use_case.dart';
import '../../../domain/usecases/get_lesson_progress_use_case.dart';
import '../../../domain/usecases/params/update_progress_params.dart';
import '../../../domain/usecases/update_lesson_progress_use_case.dart';

part 'lesson_detail_event.dart';
part 'lesson_detail_state.dart';

@injectable
class LessonDetailBloc extends Bloc<LessonDetailEvent, LessonDetailState> {
  final GetLessonByIdUseCase _getLessonById;
  final GetLessonImagesUseCase _getLessonImages;
  final GetLessonProgressUseCase _getLessonProgress;
  final UpdateLessonProgressUseCase _updateLessonProgress;

  LessonDetailBloc(
    this._getLessonById,
    this._getLessonImages,
    this._getLessonProgress,
    this._updateLessonProgress,
  ) : super(const LessonDetailInitial()) {
    on<LessonDetailLoadRequested>(_onLoadRequested);
    on<LessonProgressToggleRequested>(_onProgressToggleRequested);
  }

  Future<void> _onLoadRequested(
    LessonDetailLoadRequested event,
    Emitter<LessonDetailState> emit,
  ) async {
    emit(const LessonDetailLoading());

    final lessonResult = await _getLessonById(event.lessonId);

    await lessonResult.fold(
      (failure) async {
        emit(LessonDetailError(message: failure.message));
      },
      (lesson) async {
        final imagesResult = await _getLessonImages(event.lessonId);
        final progressResult = await _getLessonProgress(event.studentId);

        final images = imagesResult.fold(
          (_) => <LessonImage>[],
          (images) => images,
        );

        final isCompleted = progressResult.fold(
          (_) => false,
          (progressList) {
            final match = progressList.where(
              (p) => p.lessonId == event.lessonId,
            );
            return match.isNotEmpty && match.first.completed;
          },
        );

        emit(LessonDetailLoaded(
          lesson: lesson,
          images: images,
          isCompleted: isCompleted,
        ));
      },
    );
  }

  Future<void> _onProgressToggleRequested(
    LessonProgressToggleRequested event,
    Emitter<LessonDetailState> emit,
  ) async {
    final result = await _updateLessonProgress(
      UpdateProgressParams(
        lessonId: event.lessonId,
        data: {
          'student_id': event.studentId,
          'completed': event.completed,
        },
      ),
    );

    result.fold(
      (failure) => emit(LessonProgressUpdateFailure(message: failure.message)),
      (progress) => emit(
        LessonProgressUpdateSuccess(isCompleted: progress.completed),
      ),
    );
  }
}
