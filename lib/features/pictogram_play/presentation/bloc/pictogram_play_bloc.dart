import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../home/domain/entities/pictogram_entity.dart';

part 'pictogram_play_event.dart';
part 'pictogram_play_state.dart';

class PictogramPlayBloc extends Bloc<PictogramPlayEvent, PictogramPlayState> {
  Timer? _timer;
  int _totalSeconds = 0;

  PictogramPlayBloc() : super(const PictogramPlayInitial()) {
    on<StartGame>(_onStartGame);
    on<SubmitAnswer>(_onSubmitAnswer);
    on<SkipQuestion>(_onSkipQuestion);
    on<TimerTick>(_onTimerTick);
    on<NextQuestion>(_onNextQuestion);
    on<EndGame>(_onEndGame);
    on<EndGameWithResults>(_onEndGameWithResults);
    on<GoToQuestion>(_onGoToQuestion);
    on<PreviousQuestion>(_onPreviousQuestion);
  }

  void _onStartGame(StartGame event, Emitter<PictogramPlayState> emit) {
    _totalSeconds = event.timeInMinutes * 60;

    emit(PictogramPlayInProgress(
      questions: event.questions,
      currentIndex: 0,
      correctCount: 0,
      remainingSeconds: _totalSeconds,
    ));

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(const TimerTick());
    });
  }

  void _onSubmitAnswer(
    SubmitAnswer event,
    Emitter<PictogramPlayState> emit,
  ) {
    final currentState = state;
    if (currentState is! PictogramPlayInProgress) return;

    final currentQuestion = currentState.questions[currentState.currentIndex];
    final isCorrect = checkAnswer(event.answer, currentQuestion.answer);
    final result = isCorrect ? AnswerResult.correct : AnswerResult.incorrect;

    final updatedAnswers = Map<int, AnswerResult>.from(
      currentState.answeredQuestions,
    )..[currentState.currentIndex] = result;

    emit(PictogramPlayInProgress(
      questions: currentState.questions,
      currentIndex: currentState.currentIndex,
      correctCount:
          isCorrect ? currentState.correctCount + 1 : currentState.correctCount,
      remainingSeconds: currentState.remainingSeconds,
      lastAnswerResult: result,
      answeredQuestions: updatedAnswers,
    ));
  }

  void _onSkipQuestion(
    SkipQuestion event,
    Emitter<PictogramPlayState> emit,
  ) {
    final currentState = state;
    if (currentState is! PictogramPlayInProgress) return;

    final nextIndex = currentState.currentIndex + 1;

    if (nextIndex >= currentState.questions.length) {
      add(const EndGame());
      return;
    }

    emit(PictogramPlayInProgress(
      questions: currentState.questions,
      currentIndex: nextIndex,
      correctCount: currentState.correctCount,
      remainingSeconds: currentState.remainingSeconds,
      answeredQuestions: currentState.answeredQuestions,
    ));
  }

  void _onTimerTick(TimerTick event, Emitter<PictogramPlayState> emit) {
    final currentState = state;
    if (currentState is! PictogramPlayInProgress) return;

    final newRemaining = currentState.remainingSeconds - 1;

    if (newRemaining <= 0) {
      add(const EndGame());
      return;
    }

    emit(PictogramPlayInProgress(
      questions: currentState.questions,
      currentIndex: currentState.currentIndex,
      correctCount: currentState.correctCount,
      remainingSeconds: newRemaining,
    ));
  }

  void _onNextQuestion(
    NextQuestion event,
    Emitter<PictogramPlayState> emit,
  ) {
    final currentState = state;
    if (currentState is! PictogramPlayInProgress) return;

    final nextIndex = currentState.currentIndex + 1;

    if (nextIndex >= currentState.questions.length) {
      add(const EndGame());
      return;
    }

    emit(PictogramPlayInProgress(
      questions: currentState.questions,
      currentIndex: nextIndex,
      correctCount: currentState.correctCount,
      remainingSeconds: currentState.remainingSeconds,
      answeredQuestions: currentState.answeredQuestions,
    ));
  }

  void _onGoToQuestion(
    GoToQuestion event,
    Emitter<PictogramPlayState> emit,
  ) {
    final currentState = state;
    if (currentState is! PictogramPlayInProgress) return;
    if (event.index < 0 || event.index >= currentState.questions.length) return;

    emit(PictogramPlayInProgress(
      questions: currentState.questions,
      currentIndex: event.index,
      correctCount: currentState.correctCount,
      remainingSeconds: currentState.remainingSeconds,
      answeredQuestions: currentState.answeredQuestions,
    ));
  }

  void _onPreviousQuestion(
    PreviousQuestion event,
    Emitter<PictogramPlayState> emit,
  ) {
    final currentState = state;
    if (currentState is! PictogramPlayInProgress) return;
    if (currentState.currentIndex <= 0) return;

    emit(PictogramPlayInProgress(
      questions: currentState.questions,
      currentIndex: currentState.currentIndex - 1,
      correctCount: currentState.correctCount,
      remainingSeconds: currentState.remainingSeconds,
      answeredQuestions: currentState.answeredQuestions,
    ));
  }

  void _onEndGame(EndGame event, Emitter<PictogramPlayState> emit) {
    _timer?.cancel();
    _timer = null;

    final currentState = state;
    if (currentState is! PictogramPlayInProgress) return;

    final elapsedSeconds = _totalSeconds - currentState.remainingSeconds;

    emit(PictogramPlayFinished(
      correctCount: currentState.correctCount,
      totalQuestions: currentState.questions.length,
      elapsedSeconds: elapsedSeconds,
      questions: currentState.questions,
      answeredQuestions: currentState.answeredQuestions,
    ));
  }

  void _onEndGameWithResults(
    EndGameWithResults event,
    Emitter<PictogramPlayState> emit,
  ) {
    _timer?.cancel();
    _timer = null;

    final currentState = state;
    if (currentState is! PictogramPlayInProgress) return;

    final elapsedSeconds = _totalSeconds - currentState.remainingSeconds;

    emit(PictogramPlayFinished(
      correctCount: event.correctCount,
      totalQuestions: currentState.questions.length,
      elapsedSeconds: elapsedSeconds,
      questions: currentState.questions,
      answeredQuestions: event.answeredQuestions,
    ));
  }

  static bool checkAnswer(String userAnswer, String correctAnswer) =>
      userAnswer.trim().toLowerCase() == correctAnswer.trim().toLowerCase();

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}

String formatTime(int seconds) {
  final minutes = seconds ~/ 60;
  final secs = seconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
}

String formatProgress(int currentIndex, int total) =>
    'Câu ${currentIndex + 1}/$total';
