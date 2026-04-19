import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../home/domain/entities/proverb_entity.dart';
import '../../domain/word_item.dart';

part 'cdtn_play_event.dart';
part 'cdtn_play_state.dart';

class CDTNPlayBloc extends Bloc<CDTNPlayEvent, CDTNPlayState> {
  Timer? _timer;
  int _totalSeconds = 0;

  CDTNPlayBloc() : super(const CDTNPlayInitial()) {
    on<StartGame>(_onStartGame);
    on<ReorderWords>(_onReorderWords);
    on<CheckAnswer>(_onCheckAnswer);
    on<TimerTick>(_onTimerTick);
    on<NextQuestion>(_onNextQuestion);
    on<PreviousQuestion>(_onPreviousQuestion);
    on<GoToQuestion>(_onGoToQuestion);
    on<EndGame>(_onEndGame);
  }

  void _onStartGame(StartGame event, Emitter<CDTNPlayState> emit) {
    _totalSeconds = event.timeInMinutes * 60;
    final arrangements = initializeWordArrangements(event.questions);

    emit(CDTNPlayInProgress(
      questions: event.questions,
      currentIndex: 0,
      remainingSeconds: _totalSeconds,
      userWordArrangements: arrangements,
      checkStatus: null,
    ));

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(const TimerTick());
    });
  }

  void _onReorderWords(ReorderWords event, Emitter<CDTNPlayState> emit) {
    final s = state;
    if (s is! CDTNPlayInProgress) return;

    final currentWords = List<WordItem>.from(
      s.userWordArrangements[s.currentIndex],
    );
    final item = currentWords.removeAt(event.oldIndex);
    currentWords.insert(
      event.oldIndex < event.newIndex ? event.newIndex - 1 : event.newIndex,
      item,
    );

    final newArrangements = List<List<WordItem>>.from(s.userWordArrangements);
    newArrangements[s.currentIndex] = currentWords;

    emit(CDTNPlayInProgress(
      questions: s.questions,
      currentIndex: s.currentIndex,
      remainingSeconds: s.remainingSeconds,
      userWordArrangements: newArrangements,
      checkStatus: null,
    ));
  }

  void _onCheckAnswer(CheckAnswer event, Emitter<CDTNPlayState> emit) {
    final s = state;
    if (s is! CDTNPlayInProgress) return;

    final isCorrect = checkWordOrder(
      s.userWordArrangements[s.currentIndex],
      s.questions[s.currentIndex].content,
    );

    emit(CDTNPlayInProgress(
      questions: s.questions,
      currentIndex: s.currentIndex,
      remainingSeconds: s.remainingSeconds,
      userWordArrangements: s.userWordArrangements,
      checkStatus: isCorrect ? CheckStatus.correct : CheckStatus.incorrect,
    ));
  }

  void _onTimerTick(TimerTick event, Emitter<CDTNPlayState> emit) {
    final s = state;
    if (s is! CDTNPlayInProgress) return;

    final newRemaining = s.remainingSeconds - 1;

    if (newRemaining <= 0) {
      add(const EndGame());
      return;
    }

    emit(CDTNPlayInProgress(
      questions: s.questions,
      currentIndex: s.currentIndex,
      remainingSeconds: newRemaining,
      userWordArrangements: s.userWordArrangements,
      checkStatus: s.checkStatus,
    ));
  }

  void _onNextQuestion(NextQuestion event, Emitter<CDTNPlayState> emit) {
    final s = state;
    if (s is! CDTNPlayInProgress) return;
    if (s.currentIndex >= s.questions.length - 1) return;

    emit(CDTNPlayInProgress(
      questions: s.questions,
      currentIndex: s.currentIndex + 1,
      remainingSeconds: s.remainingSeconds,
      userWordArrangements: s.userWordArrangements,
      checkStatus: null,
    ));
  }

  void _onPreviousQuestion(
    PreviousQuestion event,
    Emitter<CDTNPlayState> emit,
  ) {
    final s = state;
    if (s is! CDTNPlayInProgress) return;
    if (s.currentIndex <= 0) return;

    emit(CDTNPlayInProgress(
      questions: s.questions,
      currentIndex: s.currentIndex - 1,
      remainingSeconds: s.remainingSeconds,
      userWordArrangements: s.userWordArrangements,
      checkStatus: null,
    ));
  }

  void _onGoToQuestion(GoToQuestion event, Emitter<CDTNPlayState> emit) {
    final s = state;
    if (s is! CDTNPlayInProgress) return;
    if (event.index < 0 || event.index >= s.questions.length) return;

    emit(CDTNPlayInProgress(
      questions: s.questions,
      currentIndex: event.index,
      remainingSeconds: s.remainingSeconds,
      userWordArrangements: s.userWordArrangements,
      checkStatus: null,
    ));
  }

  void _onEndGame(EndGame event, Emitter<CDTNPlayState> emit) {
    _timer?.cancel();
    _timer = null;

    final s = state;
    if (s is! CDTNPlayInProgress) return;

    final correctCount = computeCorrectCount(
      s.questions,
      s.userWordArrangements,
    );

    emit(CDTNPlayFinished(
      questions: s.questions,
      userWordArrangements: s.userWordArrangements,
      correctCount: correctCount,
      totalQuestions: s.questions.length,
      elapsedSeconds: _totalSeconds - s.remainingSeconds,
    ));
  }

  /// Splits each question's content into words, assigns unique IDs, and shuffles.
  static List<List<WordItem>> initializeWordArrangements(
    List<ProverbEntity> questions,
  ) {
    final random = Random();
    return List.generate(questions.length, (qIndex) {
      final words = questions[qIndex].content.split(RegExp(r'\s+'));
      final wordItems = List.generate(words.length, (wIndex) {
        return WordItem(
          id: 'q${qIndex}_w$wIndex',
          word: words[wIndex],
        );
      });
      wordItems.shuffle(random);
      return wordItems;
    });
  }

  /// Compares current word order with the original content.
  /// Joins words by space, trims, and compares case-insensitive.
  static bool checkWordOrder(
    List<WordItem> currentWords,
    String originalContent,
  ) {
    final userSentence =
        currentWords.map((w) => w.word).join(' ').trim().toLowerCase();
    final originalSentence = originalContent.trim().toLowerCase();
    return userSentence == originalSentence;
  }

  /// Counts the number of correctly ordered questions.
  static int computeCorrectCount(
    List<ProverbEntity> questions,
    List<List<WordItem>> userWordArrangements,
  ) {
    int count = 0;
    for (int i = 0; i < questions.length; i++) {
      if (i < userWordArrangements.length &&
          checkWordOrder(userWordArrangements[i], questions[i].content)) {
        count++;
      }
    }
    return count;
  }

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

/// Formats current question progress (e.g. "Câu 1 / 10").
String formatProgress(int currentIndex, int total) =>
    'Câu ${currentIndex + 1} / $total';

/// Calculates percentage of correct answers.
double calculatePercentage(int correct, int total) =>
    total > 0 ? (correct / total * 100) : 0;

/// Joins a list of WordItem into a sentence string.
String joinWords(List<WordItem> words) => words.map((w) => w.word).join(' ');
