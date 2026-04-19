import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../home/domain/entities/vtv_question_entity.dart';
import 'answer_status.dart';

part 'vtv_play_event.dart';
part 'vtv_play_state.dart';

class VTVPlayBloc extends Bloc<VTVPlayEvent, VTVPlayState> {
  Timer? _timer;
  int _totalSeconds = 0;

  VTVPlayBloc() : super(const VTVPlayInitial()) {
    on<StartGame>(_onStartGame);
    on<CheckAnswer>(_onCheckAnswer);
    on<ToggleHint>(_onToggleHint);
    on<TimerTick>(_onTimerTick);
    on<NextQuestion>(_onNextQuestion);
    on<PreviousQuestion>(_onPreviousQuestion);
    on<GoToQuestion>(_onGoToQuestion);
    on<UpdateAnswer>(_onUpdateAnswer);
    on<EndGame>(_onEndGame);
  }

  void _onStartGame(StartGame event, Emitter<VTVPlayState> emit) {
    _totalSeconds = event.timeInMinutes * 60;

    emit(VTVPlayInProgress(
      questions: event.questions,
      currentIndex: 0,
      remainingSeconds: _totalSeconds,
      isHintVisible: false,
      userAnswers: const {},
      answerStatuses: const {},
    ));

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(const TimerTick());
    });
  }

  void _onCheckAnswer(CheckAnswer event, Emitter<VTVPlayState> emit) {
    final currentState = state;
    if (currentState is! VTVPlayInProgress) return;

    final currentQuestion =
        currentState.questions[currentState.currentIndex];
    final isCorrect = checkAnswer(event.answer, currentQuestion.answer);
    final result =
        isCorrect ? AnswerStatus.checkedCorrect : AnswerStatus.checkedIncorrect;

    final updatedStatuses = Map<int, AnswerStatus>.from(
      currentState.answerStatuses,
    )..[currentState.currentIndex] = result;

    emit(VTVPlayInProgress(
      questions: currentState.questions,
      currentIndex: currentState.currentIndex,
      remainingSeconds: currentState.remainingSeconds,
      isHintVisible: currentState.isHintVisible,
      userAnswers: currentState.userAnswers,
      answerStatuses: updatedStatuses,
      lastCheckResult: result,
    ));
  }

  void _onToggleHint(ToggleHint event, Emitter<VTVPlayState> emit) {
    final currentState = state;
    if (currentState is! VTVPlayInProgress) return;

    emit(VTVPlayInProgress(
      questions: currentState.questions,
      currentIndex: currentState.currentIndex,
      remainingSeconds: currentState.remainingSeconds,
      isHintVisible: !currentState.isHintVisible,
      userAnswers: currentState.userAnswers,
      answerStatuses: currentState.answerStatuses,
      lastCheckResult: currentState.lastCheckResult,
    ));
  }

  void _onTimerTick(TimerTick event, Emitter<VTVPlayState> emit) {
    final currentState = state;
    if (currentState is! VTVPlayInProgress) return;

    final newRemaining = currentState.remainingSeconds - 1;

    if (newRemaining <= 0) {
      add(const EndGame());
      return;
    }

    emit(VTVPlayInProgress(
      questions: currentState.questions,
      currentIndex: currentState.currentIndex,
      remainingSeconds: newRemaining,
      isHintVisible: currentState.isHintVisible,
      userAnswers: currentState.userAnswers,
      answerStatuses: currentState.answerStatuses,
      lastCheckResult: currentState.lastCheckResult,
    ));
  }

  void _onNextQuestion(NextQuestion event, Emitter<VTVPlayState> emit) {
    final currentState = state;
    if (currentState is! VTVPlayInProgress) return;

    final nextIndex = currentState.currentIndex + 1;
    if (nextIndex >= currentState.questions.length) return;

    emit(VTVPlayInProgress(
      questions: currentState.questions,
      currentIndex: nextIndex,
      remainingSeconds: currentState.remainingSeconds,
      isHintVisible: false,
      userAnswers: currentState.userAnswers,
      answerStatuses: currentState.answerStatuses,
    ));
  }

  void _onPreviousQuestion(
    PreviousQuestion event,
    Emitter<VTVPlayState> emit,
  ) {
    final currentState = state;
    if (currentState is! VTVPlayInProgress) return;
    if (currentState.currentIndex <= 0) return;

    emit(VTVPlayInProgress(
      questions: currentState.questions,
      currentIndex: currentState.currentIndex - 1,
      remainingSeconds: currentState.remainingSeconds,
      isHintVisible: false,
      userAnswers: currentState.userAnswers,
      answerStatuses: currentState.answerStatuses,
    ));
  }

  void _onGoToQuestion(GoToQuestion event, Emitter<VTVPlayState> emit) {
    final currentState = state;
    if (currentState is! VTVPlayInProgress) return;
    if (event.index < 0 || event.index >= currentState.questions.length) return;

    emit(VTVPlayInProgress(
      questions: currentState.questions,
      currentIndex: event.index,
      remainingSeconds: currentState.remainingSeconds,
      isHintVisible: false,
      userAnswers: currentState.userAnswers,
      answerStatuses: currentState.answerStatuses,
    ));
  }

  void _onUpdateAnswer(UpdateAnswer event, Emitter<VTVPlayState> emit) {
    final currentState = state;
    if (currentState is! VTVPlayInProgress) return;

    final updatedAnswers = Map<int, String>.from(
      currentState.userAnswers,
    )..[currentState.currentIndex] = event.answer;

    final updatedStatuses = Map<int, AnswerStatus>.from(
      currentState.answerStatuses,
    );

    // Mark as answered if text is not empty, but only if not already checked
    final currentStatus =
        updatedStatuses[currentState.currentIndex] ?? AnswerStatus.unanswered;
    if (currentStatus != AnswerStatus.checkedCorrect &&
        currentStatus != AnswerStatus.checkedIncorrect) {
      updatedStatuses[currentState.currentIndex] = event.answer.trim().isEmpty
          ? AnswerStatus.unanswered
          : AnswerStatus.answered;
    }

    emit(VTVPlayInProgress(
      questions: currentState.questions,
      currentIndex: currentState.currentIndex,
      remainingSeconds: currentState.remainingSeconds,
      isHintVisible: currentState.isHintVisible,
      userAnswers: updatedAnswers,
      answerStatuses: updatedStatuses,
      lastCheckResult: currentState.lastCheckResult,
    ));
  }

  void _onEndGame(EndGame event, Emitter<VTVPlayState> emit) {
    _timer?.cancel();
    _timer = null;

    final currentState = state;
    if (currentState is! VTVPlayInProgress) return;

    final correctCount = currentState.answerStatuses.values
        .where((s) => s == AnswerStatus.checkedCorrect)
        .length;
    final elapsedSeconds = _totalSeconds - currentState.remainingSeconds;

    emit(VTVPlayFinished(
      questions: currentState.questions,
      userAnswers: currentState.userAnswers,
      answerStatuses: currentState.answerStatuses,
      correctCount: correctCount,
      totalQuestions: currentState.questions.length,
      elapsedSeconds: elapsedSeconds,
    ));
  }

  /// Compares user answer with correct answer (case-insensitive, trimmed).
  static bool checkAnswer(String userAnswer, String correctAnswer) =>
      userAnswer.trim().toLowerCase() == correctAnswer.trim().toLowerCase();

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}

/// Formats seconds into MM:SS display string.
String formatTime(int seconds) {
  final minutes = seconds ~/ 60;
  final secs = seconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
}

/// Formats current question progress (e.g. "Câu 1/10").
String formatProgress(int currentIndex, int total) =>
    'Câu ${currentIndex + 1}/$total';

/// Calculates percentage of correct answers.
double calculatePercentage(int correct, int total) =>
    total > 0 ? (correct / total * 100) : 0;
