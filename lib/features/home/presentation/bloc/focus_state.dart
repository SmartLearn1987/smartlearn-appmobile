import 'package:equatable/equatable.dart';

enum FocusMode { clock, stopwatch, pomodoro }

class FocusState extends Equatable {
  final FocusMode mode;
  final Duration elapsed;
  final Duration remaining;
  final int pomodoroMinutes;
  final bool isRunning;
  final bool pomodoroCompleted;

  const FocusState({
    this.mode = FocusMode.clock,
    this.elapsed = Duration.zero,
    this.remaining = const Duration(minutes: 5),
    this.pomodoroMinutes = 5,
    this.isRunning = false,
    this.pomodoroCompleted = false,
  });

  FocusState copyWith({
    FocusMode? mode,
    Duration? elapsed,
    Duration? remaining,
    int? pomodoroMinutes,
    bool? isRunning,
    bool? pomodoroCompleted,
  }) {
    return FocusState(
      mode: mode ?? this.mode,
      elapsed: elapsed ?? this.elapsed,
      remaining: remaining ?? this.remaining,
      pomodoroMinutes: pomodoroMinutes ?? this.pomodoroMinutes,
      isRunning: isRunning ?? this.isRunning,
      pomodoroCompleted: pomodoroCompleted ?? this.pomodoroCompleted,
    );
  }

  @override
  List<Object?> get props => [
        mode,
        elapsed,
        remaining,
        pomodoroMinutes,
        isRunning,
        pomodoroCompleted,
      ];
}
