import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'focus_state.dart';

@injectable
class FocusCubit extends Cubit<FocusState> {
  Timer? _stopwatchTimer;
  Timer? _pomodoroTimer;

  FocusCubit() : super(const FocusState());

  void switchMode(FocusMode mode) {
    _cancelAllTimers();
    emit(FocusState(mode: mode));
  }

  // --- Stopwatch ---

  void startStopwatch() {
    _stopwatchTimer?.cancel();
    emit(state.copyWith(isRunning: true, elapsed: Duration.zero));
    _stopwatchTimer = Timer.periodic(
      const Duration(milliseconds: 10),
      (_) {
        emit(state.copyWith(
          elapsed: state.elapsed + const Duration(milliseconds: 10),
        ));
      },
    );
  }

  void stopStopwatch() {
    _stopwatchTimer?.cancel();
    emit(state.copyWith(isRunning: false));
  }

  void resumeStopwatch() {
    _stopwatchTimer?.cancel();
    emit(state.copyWith(isRunning: true));
    _stopwatchTimer = Timer.periodic(
      const Duration(milliseconds: 10),
      (_) {
        emit(state.copyWith(
          elapsed: state.elapsed + const Duration(milliseconds: 10),
        ));
      },
    );
  }

  void resetStopwatch() {
    _stopwatchTimer?.cancel();
    emit(state.copyWith(
      isRunning: false,
      elapsed: Duration.zero,
    ));
  }

  // --- Pomodoro ---

  void setPomodoroMinutes(int minutes) {
    if (minutes < 1) return;
    emit(state.copyWith(
      pomodoroMinutes: minutes,
      remaining: Duration(minutes: minutes),
      pomodoroCompleted: false,
    ));
  }

  void startPomodoro() {
    _pomodoroTimer?.cancel();
    emit(state.copyWith(
      isRunning: true,
      remaining: Duration(minutes: state.pomodoroMinutes),
      pomodoroCompleted: false,
    ));
    _pomodoroTimer = Timer.periodic(
      const Duration(milliseconds: 10),
      (_) {
        final newRemaining =
            state.remaining - const Duration(milliseconds: 10);
        if (newRemaining <= Duration.zero) {
          _pomodoroTimer?.cancel();
          emit(state.copyWith(
            remaining: Duration.zero,
            isRunning: false,
            pomodoroCompleted: true,
          ));
        } else {
          emit(state.copyWith(remaining: newRemaining));
        }
      },
    );
  }

  void resetPomodoro() {
    _pomodoroTimer?.cancel();
    emit(state.copyWith(
      isRunning: false,
      remaining: Duration(minutes: state.pomodoroMinutes),
      pomodoroCompleted: false,
    ));
  }

  void _cancelAllTimers() {
    _stopwatchTimer?.cancel();
    _pomodoroTimer?.cancel();
  }

  @override
  Future<void> close() {
    _cancelAllTimers();
    return super.close();
  }
}
