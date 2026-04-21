import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../home/domain/entities/learning_question_entity.dart';

part 'hcb_play_event.dart';
part 'hcb_play_state.dart';

class HCBPlayBloc extends Bloc<HCBPlayEvent, HCBPlayState> {
  Timer? _autoPlayTimer;

  HCBPlayBloc() : super(const HCBInitial()) {
    on<StartGame>(_onStartGame);
    on<FlipCard>(_onFlipCard);
    on<NextCard>(_onNextCard);
    on<PreviousCard>(_onPreviousCard);
    on<ToggleAutoPlay>(_onToggleAutoPlay);
    on<ShuffleCards>(_onShuffleCards);
    on<_AutoPlayFlip>(_onAutoPlayFlip);
    on<_AutoPlayAdvance>(_onAutoPlayAdvance);
  }

  Future<void> _onStartGame(
    StartGame event,
    Emitter<HCBPlayState> emit,
  ) async {
    emit(const HCBLoading());
    await Future.delayed(const Duration(milliseconds: 1200));

    emit(HCBInProgress(
      questions: event.questions,
      generalQuestion: event.generalQuestion,
      currentIndex: 0,
      isFlipped: false,
      isAutoPlaying: false,
    ));
  }

  void _onFlipCard(FlipCard event, Emitter<HCBPlayState> emit) {
    final s = state;
    if (s is! HCBInProgress) return;

    emit(s.copyWith(isFlipped: !s.isFlipped));
  }

  void _onNextCard(NextCard event, Emitter<HCBPlayState> emit) {
    final s = state;
    if (s is! HCBInProgress) return;
    if (s.currentIndex >= s.questions.length - 1) return;

    // Manual navigation deactivates auto-play (Requirement 6.5)
    if (s.isAutoPlaying) {
      _cancelAutoPlayTimer();
    }

    emit(s.copyWith(
      currentIndex: s.currentIndex + 1,
      isFlipped: false,
      isAutoPlaying: false,
    ));
  }

  void _onPreviousCard(PreviousCard event, Emitter<HCBPlayState> emit) {
    final s = state;
    if (s is! HCBInProgress) return;
    if (s.currentIndex <= 0) return;

    // Manual navigation deactivates auto-play (Requirement 6.5)
    if (s.isAutoPlaying) {
      _cancelAutoPlayTimer();
    }

    emit(s.copyWith(
      currentIndex: s.currentIndex - 1,
      isFlipped: false,
      isAutoPlaying: false,
    ));
  }

  void _onToggleAutoPlay(
    ToggleAutoPlay event,
    Emitter<HCBPlayState> emit,
  ) {
    final s = state;
    if (s is! HCBInProgress) return;

    if (s.isAutoPlaying) {
      _cancelAutoPlayTimer();
      emit(s.copyWith(isAutoPlaying: false));
    } else {
      emit(s.copyWith(isAutoPlaying: true));
      _scheduleAutoPlayStep();
    }
  }

  void _onShuffleCards(ShuffleCards event, Emitter<HCBPlayState> emit) {
    final s = state;
    if (s is! HCBInProgress) return;

    _cancelAutoPlayTimer();

    final shuffled = List<LearningQuestionEntity>.from(s.questions)..shuffle();

    emit(s.copyWith(
      questions: shuffled,
      currentIndex: 0,
      isFlipped: false,
      isAutoPlaying: false,
    ));
  }

  // ── Auto-play internal handlers ──────────────────────────────────────

  void _onAutoPlayFlip(_AutoPlayFlip event, Emitter<HCBPlayState> emit) {
    final s = state;
    if (s is! HCBInProgress || !s.isAutoPlaying) return;

    emit(s.copyWith(isFlipped: true));

    // After showing back, wait 4s then advance (or stop if last card)
    _autoPlayTimer = Timer(const Duration(seconds: 4), () {
      final current = state;
      if (current is HCBInProgress && current.isAutoPlaying) {
        if (current.currentIndex >= current.questions.length - 1) {
          // Last card — stop auto-play after showing back
          add(const ToggleAutoPlay());
        } else {
          add(const _AutoPlayAdvance());
        }
      }
    });
  }

  void _onAutoPlayAdvance(
    _AutoPlayAdvance event,
    Emitter<HCBPlayState> emit,
  ) {
    final s = state;
    if (s is! HCBInProgress || !s.isAutoPlaying) return;
    if (s.currentIndex >= s.questions.length - 1) return;

    emit(s.copyWith(
      currentIndex: s.currentIndex + 1,
      isFlipped: false,
    ));

    // Continue the cycle — schedule next flip
    _scheduleAutoPlayStep();
  }

  // ── Auto-play timer management ───────────────────────────────────────

  /// Schedules the next auto-play step.
  ///
  /// Auto-play cycle:
  /// 1. If front is showing → flip to back immediately
  /// 2. Wait 4 seconds → advance to next card (front)
  /// 3. Repeat until last card's back is shown
  void _scheduleAutoPlayStep() {
    _cancelAutoPlayTimer();

    final s = state;
    if (s is! HCBInProgress || !s.isAutoPlaying) return;

    if (!s.isFlipped) {
      // Front is showing — flip to back
      add(const _AutoPlayFlip());
    } else {
      // Already showing back — wait then advance
      _autoPlayTimer = Timer(const Duration(seconds: 4), () {
        final current = state;
        if (current is HCBInProgress && current.isAutoPlaying) {
          if (current.currentIndex >= current.questions.length - 1) {
            add(const ToggleAutoPlay());
          } else {
            add(const _AutoPlayAdvance());
          }
        }
      });
    }
  }

  void _cancelAutoPlayTimer() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
  }

  @override
  Future<void> close() {
    _cancelAutoPlayTimer();
    return super.close();
  }
}

/// Formats current card progress (e.g. "CÂU 1 / 10").
String formatHCBProgress(int currentIndex, int total) =>
    'CÂU ${currentIndex + 1} / $total';
