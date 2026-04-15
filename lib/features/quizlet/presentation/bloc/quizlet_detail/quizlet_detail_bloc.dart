import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/quizlet_detail_entity.dart';
import '../../../domain/usecases/get_quizlet_detail_use_case.dart';

part 'quizlet_detail_event.dart';
part 'quizlet_detail_state.dart';

@injectable
class QuizletDetailBloc
    extends Bloc<QuizletDetailEvent, QuizletDetailState> {
  final GetQuizletDetailUseCase _getQuizletDetail;

  QuizletDetailBloc(this._getQuizletDetail)
      : super(const QuizletDetailInitial()) {
    on<LoadQuizletDetail>(_onLoadQuizletDetail);
    on<FlipCard>(_onFlipCard);
    on<NextCard>(_onNextCard);
    on<PreviousCard>(_onPreviousCard);
  }

  Future<void> _onLoadQuizletDetail(
    LoadQuizletDetail event,
    Emitter<QuizletDetailState> emit,
  ) async {
    emit(const QuizletDetailLoading());
    final result = await _getQuizletDetail(event.quizletId);
    result.fold(
      (failure) => emit(QuizletDetailError(message: failure.message)),
      (detail) => emit(QuizletDetailLoaded(
        detail: detail,
        currentIndex: 0,
        isFlipped: false,
      )),
    );
  }

  void _onFlipCard(
    FlipCard event,
    Emitter<QuizletDetailState> emit,
  ) {
    final currentState = state;
    if (currentState is QuizletDetailLoaded) {
      emit(QuizletDetailLoaded(
        detail: currentState.detail,
        currentIndex: currentState.currentIndex,
        isFlipped: !currentState.isFlipped,
      ));
    }
  }

  void _onNextCard(
    NextCard event,
    Emitter<QuizletDetailState> emit,
  ) {
    final currentState = state;
    if (currentState is QuizletDetailLoaded) {
      if (currentState.currentIndex < currentState.detail.terms.length - 1) {
        emit(QuizletDetailLoaded(
          detail: currentState.detail,
          currentIndex: currentState.currentIndex + 1,
          isFlipped: false,
        ));
      }
    }
  }

  void _onPreviousCard(
    PreviousCard event,
    Emitter<QuizletDetailState> emit,
  ) {
    final currentState = state;
    if (currentState is QuizletDetailLoaded) {
      if (currentState.currentIndex > 0) {
        emit(QuizletDetailLoaded(
          detail: currentState.detail,
          currentIndex: currentState.currentIndex - 1,
          isFlipped: false,
        ));
      }
    }
  }
}
