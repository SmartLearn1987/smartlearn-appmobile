import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/services/tts_service.dart';
import '../../../home/domain/entities/dictation_entity.dart';
import '../../domain/utils/compare_words.dart';
import '../../domain/value_objects/dictation_result.dart';
import '../../domain/value_objects/word_comparison.dart';

part 'dictation_play_event.dart';
part 'dictation_play_state.dart';

@injectable
class DictationPlayBloc extends Bloc<DictationPlayEvent, DictationPlayState> {
  final TtsService _ttsService;
  StreamSubscription<TtsState>? _ttsSubscription;

  DictationPlayBloc(this._ttsService) : super(const DictationPlayInitial()) {
    on<StartDictation>(_onStartDictation);
    on<PlayAudio>(_onPlayAudio);
    on<ReplayAudio>(_onReplayAudio);
    on<UpdateUserInput>(_onUpdateUserInput);
    on<SubmitAnswer>(_onSubmitAnswer);
    on<PlayAgain>(_onPlayAgain);
    on<_TtsStateChanged>(_onTtsStateChanged);

    _ttsSubscription = _ttsService.stateStream.listen((ttsState) {
      add(_TtsStateChanged(ttsState: ttsState));
    });
  }

  void _onStartDictation(
    StartDictation event,
    Emitter<DictationPlayState> emit,
  ) {
    emit(DictationPlayInProgress(entity: event.entity));
    _ttsService.speak(event.entity.content, event.entity.language);
  }

  void _onPlayAudio(
    PlayAudio event,
    Emitter<DictationPlayState> emit,
  ) {
    final currentState = state;
    if (currentState is! DictationPlayInProgress) return;

    emit(DictationPlayInProgress(
      entity: currentState.entity,
      userInput: currentState.userInput,
      isPlaying: true,
      wordCount: currentState.wordCount,
    ));
    _ttsService.speak(currentState.entity.content, currentState.entity.language);
  }

  void _onReplayAudio(
    ReplayAudio event,
    Emitter<DictationPlayState> emit,
  ) {
    final currentState = state;
    if (currentState is! DictationPlayInProgress) return;

    emit(DictationPlayInProgress(
      entity: currentState.entity,
      userInput: currentState.userInput,
      isPlaying: true,
      wordCount: currentState.wordCount,
    ));
    _ttsService.speak(currentState.entity.content, currentState.entity.language);
  }

  void _onUpdateUserInput(
    UpdateUserInput event,
    Emitter<DictationPlayState> emit,
  ) {
    final currentState = state;
    if (currentState is! DictationPlayInProgress) return;

    emit(DictationPlayInProgress(
      entity: currentState.entity,
      userInput: event.text,
      isPlaying: currentState.isPlaying,
      wordCount: countWords(event.text),
    ));
  }

  void _onSubmitAnswer(
    SubmitAnswer event,
    Emitter<DictationPlayState> emit,
  ) {
    final currentState = state;
    if (currentState is! DictationPlayInProgress) return;

    final (wordComparisons, result) = compareWords(
      currentState.entity.content,
      currentState.userInput,
    );

    emit(DictationPlayFinished(
      entity: currentState.entity,
      userInput: currentState.userInput,
      result: result,
      wordComparisons: wordComparisons,
    ));
  }

  void _onPlayAgain(
    PlayAgain event,
    Emitter<DictationPlayState> emit,
  ) {
    // PlayAgain is handled by the UI (navigation), emit initial state.
    emit(const DictationPlayInitial());
  }

  void _onTtsStateChanged(
    _TtsStateChanged event,
    Emitter<DictationPlayState> emit,
  ) {
    final currentState = state;
    if (currentState is! DictationPlayInProgress) return;

    final isPlaying = event.ttsState == TtsState.playing;

    if (currentState.isPlaying != isPlaying) {
      emit(DictationPlayInProgress(
        entity: currentState.entity,
        userInput: currentState.userInput,
        isPlaying: isPlaying,
        wordCount: currentState.wordCount,
      ));
    }
  }

  @override
  Future<void> close() {
    _ttsSubscription?.cancel();
    _ttsService.stop();
    return super.close();
  }
}
