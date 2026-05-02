import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../home/domain/entities/nnc_question_entity.dart';

part 'nnc_play_event.dart';
part 'nnc_play_state.dart';

class NNCPlayBloc extends Bloc<NNCPlayEvent, NNCPlayState> {
  Timer? _timer;
  Timer? _autoAdvanceTimer;
  int _totalSeconds = 0;

  NNCPlayBloc() : super(const NNCPlayInitial()) {
    on<StartGame>(_onStartGame);
    on<SelectAnswer>(_onSelectAnswer);
    on<TimerTick>(_onTimerTick);
    on<NextQuestion>(_onNextQuestion);
    on<PreviousQuestion>(_onPreviousQuestion);
    on<GoToQuestion>(_onGoToQuestion);
    on<EndGame>(_onEndGame);
    on<RestartGame>(_onRestartGame);
  }

  Future<void> _onStartGame(
    StartGame event,
    Emitter<NNCPlayState> emit,
  ) async {
    _totalSeconds = event.timeInMinutes * 60;

    emit(const NNCPlayLoading());
    await Future.delayed(const Duration(milliseconds: 1200));

    emit(NNCPlayInProgress(
      questions: event.questions,
      currentIndex: 0,
      remainingSeconds: _totalSeconds,
      userAnswers: List.filled(event.questions.length, -1),
    ));

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(const TimerTick());
    });
  }

  void _onSelectAnswer(SelectAnswer event, Emitter<NNCPlayState> emit) {
    final s = state;
    if (s is! NNCPlayInProgress) return;

    final newAnswers = List<int>.from(s.userAnswers);
    newAnswers[s.currentIndex] = event.optionIndex;

    emit(NNCPlayInProgress(
      questions: s.questions,
      currentIndex: s.currentIndex,
      remainingSeconds: s.remainingSeconds,
      userAnswers: newAnswers,
    ));

    _autoAdvanceTimer?.cancel();
    if (s.currentIndex < s.questions.length - 1) {
      _autoAdvanceTimer = Timer(
        const Duration(milliseconds: 300),
        () => add(const NextQuestion()),
      );
    }
  }

  void _onTimerTick(TimerTick event, Emitter<NNCPlayState> emit) {
    final s = state;
    if (s is! NNCPlayInProgress) return;

    final newRemaining = s.remainingSeconds - 1;

    if (newRemaining <= 0) {
      add(const EndGame());
      return;
    }

    emit(NNCPlayInProgress(
      questions: s.questions,
      currentIndex: s.currentIndex,
      remainingSeconds: newRemaining,
      userAnswers: s.userAnswers,
    ));
  }

  void _onNextQuestion(NextQuestion event, Emitter<NNCPlayState> emit) {
    final s = state;
    if (s is! NNCPlayInProgress) return;

    final nextIndex = s.currentIndex + 1;
    if (nextIndex >= s.questions.length) return;

    _autoAdvanceTimer?.cancel();

    emit(NNCPlayInProgress(
      questions: s.questions,
      currentIndex: nextIndex,
      remainingSeconds: s.remainingSeconds,
      userAnswers: s.userAnswers,
    ));
  }

  void _onPreviousQuestion(
    PreviousQuestion event,
    Emitter<NNCPlayState> emit,
  ) {
    final s = state;
    if (s is! NNCPlayInProgress) return;
    if (s.currentIndex <= 0) return;

    _autoAdvanceTimer?.cancel();

    emit(NNCPlayInProgress(
      questions: s.questions,
      currentIndex: s.currentIndex - 1,
      remainingSeconds: s.remainingSeconds,
      userAnswers: s.userAnswers,
    ));
  }

  void _onGoToQuestion(GoToQuestion event, Emitter<NNCPlayState> emit) {
    final s = state;
    if (s is! NNCPlayInProgress) return;
    if (event.index < 0 || event.index >= s.questions.length) return;

    _autoAdvanceTimer?.cancel();

    emit(NNCPlayInProgress(
      questions: s.questions,
      currentIndex: event.index,
      remainingSeconds: s.remainingSeconds,
      userAnswers: s.userAnswers,
    ));
  }

  void _onEndGame(EndGame event, Emitter<NNCPlayState> emit) {
    _timer?.cancel();
    _timer = null;
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = null;

    final s = state;
    if (s is! NNCPlayInProgress) return;

    final correctCount = computeCorrectCount(s.questions, s.userAnswers);
    final elapsedSeconds = _totalSeconds - s.remainingSeconds;

    emit(NNCPlayFinished(
      questions: s.questions,
      userAnswers: s.userAnswers,
      correctCount: correctCount,
      totalQuestions: s.questions.length,
      elapsedSeconds: elapsedSeconds,
    ));
  }

  void _onRestartGame(RestartGame event, Emitter<NNCPlayState> emit) {
    final s = state;
    if (s is! NNCPlayFinished) return;

    add(StartGame(
      questions: s.questions,
      timeInMinutes: _totalSeconds ~/ 60,
    ));
  }

  /// Đếm số câu trả lời đúng bằng cách so sánh userAnswers[i] với
  /// questions[i].correctIndex.
  static int computeCorrectCount(
    List<NNCQuestionEntity> questions,
    List<int> userAnswers,
  ) {
    int count = 0;
    for (int i = 0; i < questions.length; i++) {
      if (i < userAnswers.length &&
          userAnswers[i] == questions[i].correctIndex) {
        count++;
      }
    }
    return count;
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _autoAdvanceTimer?.cancel();
    return super.close();
  }
}

/// Formats seconds into MM:SS display string.
String formatTime(int seconds) {
  final minutes = seconds ~/ 60;
  final secs = seconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
}

/// Formats current question progress (e.g. "Thử thách 1 / 10").
String formatProgress(int currentIndex, int total) =>
    'Thử thách ${currentIndex + 1} / $total';

/// Calculates percentage of correct answers.
double calculatePercentage(int correct, int total) =>
    total > 0 ? (correct / total * 100) : 0;

/// Tính phần trăm câu đã trả lời (userAnswers[i] != -1).
double calculateAnsweredPercentage(List<int> userAnswers) {
  if (userAnswers.isEmpty) return 0;
  final answered = userAnswers.where((a) => a != -1).length;
  return answered / userAnswers.length;
}
