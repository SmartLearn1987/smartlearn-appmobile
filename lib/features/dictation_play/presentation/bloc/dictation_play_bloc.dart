import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../home/domain/entities/dictation_entity.dart';
import '../../../home/domain/usecases/get_random_dictation.dart';
import '../../domain/utils/compare_words.dart';
import '../../domain/value_objects/dictation_result.dart';
import '../../domain/value_objects/word_comparison.dart';

part 'dictation_play_event.dart';
part 'dictation_play_state.dart';

@injectable
class DictationPlayBloc extends Bloc<DictationPlayEvent, DictationPlayState> {
  DictationPlayBloc(this._getRandomDictation)
    : super(const DictationPlayInitial()) {
    on<StartDictation>(_onStartDictation);
    on<UpdateUserInput>(_onUpdateUserInput);
    on<SubmitAnswer>(_onSubmitAnswer);
    on<PlayAgain>(_onPlayAgain);
    on<TimerTick>(_onTimerTick);
    on<LoadNewDictation>(_onLoadNewDictation);
  }

  final GetRandomDictationUseCase _getRandomDictation;
  Timer? _timer;

  void _onStartDictation(
    StartDictation event,
    Emitter<DictationPlayState> emit,
  ) {
    emit(DictationPlayInProgress(entity: event.entity));
    _restartTimer();
  }

  void _onUpdateUserInput(
    UpdateUserInput event,
    Emitter<DictationPlayState> emit,
  ) {
    final s = state;
    if (s is! DictationPlayInProgress) return;

    emit(s.copyWith(
      userInput: event.text,
      wordCount: countWords(event.text),
    ));
  }

  void _onSubmitAnswer(
    SubmitAnswer event,
    Emitter<DictationPlayState> emit,
  ) {
    final s = state;
    if (s is! DictationPlayInProgress) return;

    _timer?.cancel();
    _timer = null;

    final (wordComparisons, result) = compareWords(
      s.entity.content,
      s.userInput,
    );

    emit(DictationPlayFinished(
      entity: s.entity,
      userInput: s.userInput,
      result: result,
      wordComparisons: wordComparisons,
      elapsedSeconds: s.elapsedSeconds,
    ));
  }

  void _onPlayAgain(
    PlayAgain event,
    Emitter<DictationPlayState> emit,
  ) {
    final s = state;
    if (s is! DictationPlayFinished) return;
    emit(DictationPlayInProgress(entity: s.entity));
    _restartTimer();
  }

  void _onTimerTick(TimerTick event, Emitter<DictationPlayState> emit) {
    final s = state;
    if (s is! DictationPlayInProgress) return;
    emit(s.copyWith(elapsedSeconds: s.elapsedSeconds + 1));
  }

  Future<void> _onLoadNewDictation(
    LoadNewDictation event,
    Emitter<DictationPlayState> emit,
  ) async {
    final s = state;

    final DictationEntity sourceEntity;
    if (s is DictationPlayInProgress) {
      if (s.isLoadingNew) return;
      sourceEntity = s.entity;
      emit(s.copyWith(isLoadingNew: true, clearErrorMessage: true));
    } else if (s is DictationPlayFinished) {
      if (s.isLoadingNew) return;
      sourceEntity = s.entity;
      emit(s.copyWith(isLoadingNew: true, clearErrorMessage: true));
    } else {
      return;
    }

    final result = await _getRandomDictation(
      DictationParams(
        level: sourceEntity.level,
        language: sourceEntity.language,
      ),
    );

    result.fold(
      (failure) {
        final current = state;
        if (current is DictationPlayInProgress) {
          emit(current.copyWith(
            isLoadingNew: false,
            errorMessage: failure.message,
          ));
        } else if (current is DictationPlayFinished) {
          emit(current.copyWith(
            isLoadingNew: false,
            errorMessage: failure.message,
          ));
        }
      },
      (newEntity) {
        emit(DictationPlayInProgress(entity: newEntity));
        _restartTimer();
      },
    );
  }

  void _restartTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(const TimerTick());
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}

/// Format giây thành chuỗi MM:SS.
String formatElapsed(int seconds) {
  final minutes = seconds ~/ 60;
  final secs = seconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
}
