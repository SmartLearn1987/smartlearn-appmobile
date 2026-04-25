import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/usecase/usecase.dart';
import '../../../domain/entities/quizlet_entity.dart';
import '../../../domain/usecases/delete_quizlet_use_case.dart';
import '../../../domain/usecases/get_quizlets_use_case.dart';
import '../../helpers/quizlet_filter_helper.dart';

part 'quizlet_event.dart';
part 'quizlet_state.dart';

@injectable
class QuizletBloc extends Bloc<QuizletEvent, QuizletState> {
  final GetQuizletsUseCase _getQuizlets;
  final DeleteQuizletUseCase _deleteQuizlet;
  String _currentUserId = '';
  String? _currentUserEducationLevel;

  QuizletBloc(this._getQuizlets, this._deleteQuizlet)
    : super(const QuizletInitial()) {
    on<SyncUserContext>(_onSyncUserContext);
    on<LoadQuizlets>(_onLoadQuizlets);
    on<RefreshQuizlets>(_onRefreshQuizlets);
    on<ChangeViewMode>(_onChangeViewMode);
    on<SearchQuizlets>(_onSearchQuizlets);
    on<DeleteQuizlet>(_onDeleteQuizlet);
  }

  Future<void> _onLoadQuizlets(
    LoadQuizlets event,
    Emitter<QuizletState> emit,
  ) async {
    emit(const QuizletLoading());
    await _fetchQuizlets(emit);
  }

  Future<void> _onRefreshQuizlets(
    RefreshQuizlets event,
    Emitter<QuizletState> emit,
  ) async {
    emit(const QuizletLoading());
    await _fetchQuizlets(emit);
  }

  Future<void> _onSyncUserContext(
    SyncUserContext event,
    Emitter<QuizletState> emit,
  ) async {
    _currentUserId = event.userId;
    _currentUserEducationLevel = event.educationLevel;

    final currentState = state;
    if (currentState is! QuizletLoaded) {
      return;
    }

    emit(
      currentState.copyWith(
        filteredQuizlets: _applyFilters(
          allQuizlets: currentState.allQuizlets,
          viewMode: currentState.viewMode,
          searchQuery: currentState.searchQuery,
        ),
      ),
    );
  }

  Future<void> _fetchQuizlets(Emitter<QuizletState> emit) async {
    final result = await _getQuizlets(const NoParams());
    result.fold((failure) => emit(QuizletError(message: failure.message)), (
      quizlets,
    ) {
      const viewMode = ViewMode.community;
      const searchQuery = '';
      final filteredQuizlets = _applyFilters(
        allQuizlets: quizlets,
        viewMode: viewMode,
        searchQuery: searchQuery,
      );
      emit(
        QuizletLoaded(
          allQuizlets: quizlets,
          filteredQuizlets: filteredQuizlets,
          viewMode: viewMode,
          searchQuery: searchQuery,
        ),
      );
    });
  }

  Future<void> _onChangeViewMode(
    ChangeViewMode event,
    Emitter<QuizletState> emit,
  ) async {
    final currentState = state;
    if (currentState is! QuizletLoaded) {
      return;
    }

    emit(
      currentState.copyWith(
        viewMode: event.viewMode,
        filteredQuizlets: _applyFilters(
          allQuizlets: currentState.allQuizlets,
          viewMode: event.viewMode,
          searchQuery: currentState.searchQuery,
        ),
      ),
    );
  }

  Future<void> _onSearchQuizlets(
    SearchQuizlets event,
    Emitter<QuizletState> emit,
  ) async {
    final currentState = state;
    if (currentState is! QuizletLoaded) {
      return;
    }

    emit(
      currentState.copyWith(
        searchQuery: event.query,
        filteredQuizlets: _applyFilters(
          allQuizlets: currentState.allQuizlets,
          viewMode: currentState.viewMode,
          searchQuery: event.query,
        ),
      ),
    );
  }

  Future<void> _onDeleteQuizlet(
    DeleteQuizlet event,
    Emitter<QuizletState> emit,
  ) async {
    final currentState = state;
    if (currentState is! QuizletLoaded) {
      return;
    }

    final result = await _deleteQuizlet(event.id);
    result.fold((failure) => emit(QuizletError(message: failure.message)), (_) {
      final updatedAllQuizlets = currentState.allQuizlets
          .where((quizlet) => quizlet.id != event.id)
          .toList();
      emit(
        currentState.copyWith(
          allQuizlets: updatedAllQuizlets,
          filteredQuizlets: _applyFilters(
            allQuizlets: updatedAllQuizlets,
            viewMode: currentState.viewMode,
            searchQuery: currentState.searchQuery,
          ),
        ),
      );
    });
  }

  List<QuizletEntity> _applyFilters({
    required List<QuizletEntity> allQuizlets,
    required ViewMode viewMode,
    required String searchQuery,
  }) {
    return filterQuizlets(
      allQuizlets: allQuizlets,
      viewMode: viewMode,
      currentUserId: _currentUserId,
      currentUserEducationLevel: _currentUserEducationLevel,
      searchQuery: searchQuery,
    );
  }
}
