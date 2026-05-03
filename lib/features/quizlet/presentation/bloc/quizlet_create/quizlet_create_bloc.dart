import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/features/home/domain/entities/subject_entity.dart';
import 'package:smart_learn/features/quizlet/domain/usecases/create_quizlet_use_case.dart';
import 'package:smart_learn/features/quizlet/domain/usecases/get_quizlet_detail_use_case.dart';
import 'package:smart_learn/features/quizlet/domain/usecases/params/create_quizlet_params.dart';
import 'package:smart_learn/features/quizlet/domain/usecases/params/update_quizlet_params.dart';
import 'package:smart_learn/features/quizlet/domain/usecases/update_quizlet_use_case.dart';
import 'package:smart_learn/features/quizlet/presentation/helpers/csv_import_helper.dart';
import 'package:smart_learn/features/subjects/domain/usecases/get_subjects_use_case.dart';

part 'quizlet_create_event.dart';
part 'quizlet_create_state.dart';

@injectable
class QuizletCreateBloc extends Bloc<QuizletCreateEvent, QuizletCreateState> {
  final CreateQuizletUseCase _createQuizlet;
  final UpdateQuizletUseCase _updateQuizlet;
  final GetQuizletDetailUseCase _getQuizletDetail;
  final GetSubjectsUseCase _getSubjects;

  QuizletCreateBloc(
    this._createQuizlet,
    this._updateQuizlet,
    this._getQuizletDetail,
    this._getSubjects,
  ) : super(const QuizletCreateState()) {
    on<LoadSubjects>(_onLoadSubjects);
    on<LoadQuizletForEdit>(_onLoadQuizletForEdit);
    on<UpdateTitle>(_onUpdateTitle);
    on<UpdateDescription>(_onUpdateDescription);
    on<ToggleVisibility>(_onToggleVisibility);
    on<SelectSubject>(_onSelectSubject);
    on<SelectEducationLevel>(_onSelectEducationLevel);
    on<UpdateGrade>(_onUpdateGrade);
    on<AddCard>(_onAddCard);
    on<RemoveCard>(_onRemoveCard);
    on<UpdateCard>(_onUpdateCard);
    on<ImportCards>(_onImportCards);
    on<SubmitQuizlet>(_onSubmitQuizlet);
  }

  Future<void> _onLoadSubjects(
    LoadSubjects event,
    Emitter<QuizletCreateState> emit,
  ) async {
    final result = await _getSubjects(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (subjects) =>
          emit(state.copyWith(subjects: subjects, errorMessage: null)),
    );
  }

  Future<void> _onLoadQuizletForEdit(
    LoadQuizletForEdit event,
    Emitter<QuizletCreateState> emit,
  ) async {
    emit(state.copyWith(isLoadingDetail: true, errorMessage: null));
    final result = await _getQuizletDetail(event.quizletId);
    result.fold(
      (failure) => emit(
        state.copyWith(isLoadingDetail: false, errorMessage: failure.message),
      ),
      (detail) {
        final cards = detail.terms
            .map(
              (term) =>
                  CardFormData(term: term.term, definition: term.definition),
            )
            .toList();
        emit(
          state.copyWith(
            isLoadingDetail: false,
            isEditMode: true,
            quizletId: detail.id,
            title: detail.title,
            description: detail.description ?? '',
            isPublic: detail.isPublic,
            selectedSubjectId: detail.subjectId,
            educationLevel: detail.educationLevel,
            grade: detail.grade ?? '',
            cards: cards.isEmpty
                ? const [CardFormData.empty(), CardFormData.empty()]
                : cards,
            errorMessage: null,
          ),
        );
      },
    );
  }

  void _onUpdateTitle(UpdateTitle event, Emitter<QuizletCreateState> emit) {
    emit(
      state.copyWith(title: event.title, isSuccess: false, errorMessage: null),
    );
  }

  void _onUpdateDescription(
    UpdateDescription event,
    Emitter<QuizletCreateState> emit,
  ) {
    emit(
      state.copyWith(
        description: event.description,
        isSuccess: false,
        errorMessage: null,
      ),
    );
  }

  void _onToggleVisibility(
    ToggleVisibility event,
    Emitter<QuizletCreateState> emit,
  ) {
    emit(
      state.copyWith(
        isPublic: event.isPublic,
        isSuccess: false,
        errorMessage: null,
      ),
    );
  }

  void _onSelectSubject(SelectSubject event, Emitter<QuizletCreateState> emit) {
    emit(
      state.copyWith(
        selectedSubjectId: event.subjectId,
        isSuccess: false,
        errorMessage: null,
      ),
    );
  }

  void _onSelectEducationLevel(
    SelectEducationLevel event,
    Emitter<QuizletCreateState> emit,
  ) {
    emit(
      state.copyWith(
        educationLevel: event.educationLevel,
        isSuccess: false,
        errorMessage: null,
      ),
    );
  }

  void _onUpdateGrade(UpdateGrade event, Emitter<QuizletCreateState> emit) {
    emit(
      state.copyWith(grade: event.grade, isSuccess: false, errorMessage: null),
    );
  }

  void _onAddCard(AddCard event, Emitter<QuizletCreateState> emit) {
    emit(
      state.copyWith(
        cards: [...state.cards, const CardFormData.empty()],
        isSuccess: false,
        errorMessage: null,
      ),
    );
  }

  void _onRemoveCard(RemoveCard event, Emitter<QuizletCreateState> emit) {
    if (state.cards.length <= 1) {
      return;
    }

    final updatedCards = [...state.cards]..removeAt(event.index);
    emit(
      state.copyWith(cards: updatedCards, isSuccess: false, errorMessage: null),
    );
  }

  void _onUpdateCard(UpdateCard event, Emitter<QuizletCreateState> emit) {
    if (event.index < 0 || event.index >= state.cards.length) {
      return;
    }

    final updatedCards = [...state.cards];
    updatedCards[event.index] = CardFormData(
      term: event.term,
      definition: event.definition,
    );
    emit(
      state.copyWith(cards: updatedCards, isSuccess: false, errorMessage: null),
    );
  }

  void _onImportCards(ImportCards event, Emitter<QuizletCreateState> emit) {
    final importedCards = parseCsvToCards(event.csvContent);
    if (importedCards.isEmpty) {
      emit(
        state.copyWith(errorMessage: 'Không tìm thấy dữ liệu hợp lệ để nhập'),
      );
      return;
    }

    final updatedCards = [...state.cards];
    var importIndex = 0;

    for (
      var i = 0;
      i < updatedCards.length && importIndex < importedCards.length;
      i++
    ) {
      if (!updatedCards[i].hasContent) {
        updatedCards[i] = importedCards[importIndex];
        importIndex++;
      }
    }

    if (importIndex < importedCards.length) {
      updatedCards.addAll(importedCards.sublist(importIndex));
    }

    emit(
      state.copyWith(cards: updatedCards, isSuccess: false, errorMessage: null),
    );
  }

  Future<void> _onSubmitQuizlet(
    SubmitQuizlet event,
    Emitter<QuizletCreateState> emit,
  ) async {
    if (state.title.trim().isEmpty) {
      emit(state.copyWith(errorMessage: 'Vui lòng nhập tiêu đề'));
      return;
    }

    final validCards = state.cards.where((card) => card.hasContent).toList();
    if (validCards.isEmpty) {
      emit(state.copyWith(errorMessage: 'Vui lòng nhập ít nhất một thuật ngữ'));
      return;
    }

    emit(
      state.copyWith(isSubmitting: true, isSuccess: false, errorMessage: null),
    );

    final terms = validCards
        .map(
          (card) => TermParams(
            term: card.term.trim(),
            definition: card.definition.trim(),
          ),
        )
        .toList();

    if (state.isEditMode && state.quizletId != null) {
      final result = await _updateQuizlet(
        UpdateQuizletParams(
          id: state.quizletId!,
          title: state.title.trim(),
          description: state.description.trim().isEmpty
              ? null
              : state.description.trim(),
          subjectId: state.selectedSubjectId,
          grade: state.grade.trim().isEmpty ? null : state.grade.trim(),
          educationLevel: state.educationLevel,
          isPublic: state.isPublic,
          terms: terms,
        ),
      );
      result.fold(
        (failure) => emit(
          state.copyWith(
            isSubmitting: false,
            isSuccess: false,
            errorMessage: failure.message,
          ),
        ),
        (_) => emit(
          state.copyWith(
            isSubmitting: false,
            isSuccess: true,
            errorMessage: null,
          ),
        ),
      );
      return;
    }

    final result = await _createQuizlet(
      CreateQuizletParams(
        title: state.title.trim(),
        description: state.description.trim().isEmpty
            ? null
            : state.description.trim(),
        subjectId: state.selectedSubjectId,
        grade: state.grade.trim().isEmpty ? null : state.grade.trim(),
        educationLevel: state.educationLevel,
        isPublic: state.isPublic,
        createdBy: 'current_user',
        terms: terms,
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          isSubmitting: false,
          isSuccess: false,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          isSubmitting: false,
          isSuccess: true,
          errorMessage: null,
        ),
      ),
    );
  }
}
