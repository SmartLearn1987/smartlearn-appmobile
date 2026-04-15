import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/usecase/usecase.dart';
import '../../../domain/entities/quizlet_entity.dart';
import '../../../domain/usecases/get_quizlets_use_case.dart';

part 'quizlet_event.dart';
part 'quizlet_state.dart';

@injectable
class QuizletBloc extends Bloc<QuizletEvent, QuizletState> {
  final GetQuizletsUseCase _getQuizlets;

  QuizletBloc(this._getQuizlets) : super(const QuizletInitial()) {
    on<LoadQuizlets>(_onLoadQuizlets);
    on<RefreshQuizlets>(_onRefreshQuizlets);
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

  Future<void> _fetchQuizlets(Emitter<QuizletState> emit) async {
    final result = await _getQuizlets(const NoParams());
    result.fold(
      (failure) => emit(QuizletError(message: failure.message)),
      (quizlets) => emit(QuizletLoaded(quizlets: quizlets)),
    );
  }
}
