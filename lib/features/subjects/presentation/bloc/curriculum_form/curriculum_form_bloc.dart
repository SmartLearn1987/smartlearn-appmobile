import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../domain/entities/curriculum_entity.dart';
import '../../../domain/usecases/create_curriculum_use_case.dart';
import '../../../domain/usecases/params/create_curriculum_params.dart';
import '../../../domain/usecases/params/update_curriculum_params.dart';
import '../../../domain/usecases/update_curriculum_use_case.dart';
import '../../../domain/usecases/upload_image_use_case.dart';
import '../../../domain/validators/curriculum_validators.dart';

part 'curriculum_form_event.dart';
part 'curriculum_form_state.dart';

@injectable
class CurriculumFormBloc
    extends Bloc<CurriculumFormEvent, CurriculumFormState> {
  final CreateCurriculumUseCase _createCurriculum;
  final UpdateCurriculumUseCase _updateCurriculum;
  final UploadImageUseCase _uploadImage;
  final AuthBloc _authBloc;

  CurriculumFormBloc(
    this._createCurriculum,
    this._updateCurriculum,
    this._uploadImage,
    this._authBloc,
  ) : super(const CurriculumFormState()) {
    on<CurriculumFormInitialized>(_onInitialized);
    on<CurriculumFormFieldChanged>(_onFieldChanged);
    on<CurriculumFormImageSelected>(_onImageSelected);
    on<CurriculumFormImageRemoved>(_onImageRemoved);
    on<CurriculumFormStepChanged>(_onStepChanged);
    on<CurriculumFormSubmitted>(_onSubmitted);
  }

  void _onInitialized(
    CurriculumFormInitialized event,
    Emitter<CurriculumFormState> emit,
  ) {
    final c = event.curriculum;
    if (c != null) {
      emit(state.copyWith(
        isEditMode: true,
        curriculumId: c.id,
        name: c.name,
        grade: c.grade ?? '',
        publisher: c.publisher ?? '',
        educationLevel: c.educationLevel ?? '',
        isPublic: c.isPublic,
        lessonCount: c.lessonCount,
        existingImageUrl: c.imageUrl,
      ));
    }
  }

  void _onFieldChanged(
    CurriculumFormFieldChanged event,
    Emitter<CurriculumFormState> emit,
  ) {
    switch (event.field) {
      case 'name':
        emit(state.copyWith(name: event.value as String));
      case 'grade':
        emit(state.copyWith(grade: event.value as String));
      case 'publisher':
        emit(state.copyWith(publisher: event.value as String));
      case 'educationLevel':
        emit(state.copyWith(educationLevel: event.value as String));
      case 'isPublic':
        emit(state.copyWith(isPublic: event.value as bool));
      case 'lessonCount':
        emit(state.copyWith(lessonCount: event.value as int));
    }
  }

  void _onImageSelected(
    CurriculumFormImageSelected event,
    Emitter<CurriculumFormState> emit,
  ) {
    emit(state.copyWith(imageFile: event.file));
  }

  void _onImageRemoved(
    CurriculumFormImageRemoved event,
    Emitter<CurriculumFormState> emit,
  ) {
    emit(state.copyWith(
      clearImageFile: true,
      clearExistingImageUrl: true,
    ));
  }

  void _onStepChanged(
    CurriculumFormStepChanged event,
    Emitter<CurriculumFormState> emit,
  ) {
    emit(state.copyWith(step: event.step));
  }

  Future<void> _onSubmitted(
    CurriculumFormSubmitted event,
    Emitter<CurriculumFormState> emit,
  ) async {
    // Validate name
    final nameError = validateCurriculumName(state.name);
    if (nameError != null) {
      emit(state.copyWith(errorMessage: nameError, step: 0));
      return;
    }

    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    final userId = _authBloc.state is AuthAuthenticated
        ? (_authBloc.state as AuthAuthenticated).user.id
        : '';

    if (state.isEditMode) {
      final result = await _updateCurriculum(UpdateCurriculumParams(
        id: state.curriculumId,
        name: state.name,
        grade: state.grade.isEmpty ? null : state.grade,
        educationLevel:
            state.educationLevel.isEmpty ? null : state.educationLevel,
        isPublic: state.isPublic,
        publisher: state.publisher.isEmpty ? null : state.publisher,
        lessonCount: state.lessonCount,
        imageFile: state.imageFile,
        existingImageUrl: state.existingImageUrl,
      ));
      result.fold(
        (failure) => emit(state.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
        )),
        (_) => emit(state.copyWith(isSubmitting: false, isSuccess: true)),
      );
    } else {
      final result = await _createCurriculum(CreateCurriculumParams(
        subjectId: event.subjectId,
        name: state.name,
        grade: state.grade.isEmpty ? null : state.grade,
        educationLevel:
            state.educationLevel.isEmpty ? null : state.educationLevel,
        isPublic: state.isPublic,
        publisher: state.publisher.isEmpty ? null : state.publisher,
        lessonCount: state.lessonCount,
        imageFile: state.imageFile,
        createdBy: userId,
      ));
      result.fold(
        (failure) => emit(state.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
        )),
        (_) => emit(state.copyWith(isSubmitting: false, isSuccess: true)),
      );
    }
  }
}
