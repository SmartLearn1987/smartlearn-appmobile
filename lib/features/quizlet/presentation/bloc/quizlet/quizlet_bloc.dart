import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

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
    await _fetchQuizlets(emit, viewMode: ViewMode.community);
  }

  Future<void> _onRefreshQuizlets(
    RefreshQuizlets event,
    Emitter<QuizletState> emit,
  ) async {
    final currentState = state;
    final isLoaded = currentState is QuizletLoaded;
    final viewMode = isLoaded ? currentState.viewMode : ViewMode.community;
    final searchQuery = isLoaded ? currentState.searchQuery : '';

    if (isLoaded) {
      emit(currentState.copyWith(isFetching: true));
    } else {
      emit(const QuizletLoading());
    }
    await _fetchQuizlets(emit, viewMode: viewMode, searchQuery: searchQuery);
  }

  Future<void> _onSyncUserContext(
    SyncUserContext event,
    Emitter<QuizletState> emit,
  ) async {
    // User context is currently consumed by UI and API auth, no local filtering.
  }

  Future<void> _fetchQuizlets(
    Emitter<QuizletState> emit, {
    required ViewMode viewMode,
    String searchQuery = '',
  }) async {
    final result = await _getQuizlets(_toApiTab(viewMode));
    result.fold((failure) => emit(QuizletError(message: failure.message)), (
      quizlets,
    ) {
      final filteredQuizlets = _applyFilters(
        allQuizlets: quizlets,
        searchQuery: searchQuery,
      );
      emit(
        QuizletLoaded(
          allQuizlets: quizlets,
          filteredQuizlets: filteredQuizlets,
          viewMode: viewMode,
          searchQuery: searchQuery,
          isFetching: false,
        ),
      );
    });
  }

  String _toApiTab(ViewMode viewMode) =>
      viewMode == ViewMode.personal ? 'personal' : 'community';

  Future<void> _onChangeViewMode(
    ChangeViewMode event,
    Emitter<QuizletState> emit,
  ) async {
    final currentState = state;
    if (currentState is! QuizletLoaded) {
      return;
    }

    if (event.viewMode == currentState.viewMode) {
      return;
    }

    emit(currentState.copyWith(viewMode: event.viewMode, isFetching: true));
    await _fetchQuizlets(
      emit,
      viewMode: event.viewMode,
      searchQuery: currentState.searchQuery,
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
            searchQuery: currentState.searchQuery,
          ),
        ),
      );
    });
  }

  List<QuizletEntity> _applyFilters({
    required List<QuizletEntity> allQuizlets,
    required String searchQuery,
  }) {
    return filterQuizlets(allQuizlets: allQuizlets, searchQuery: searchQuery);
  }
}
