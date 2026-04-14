// Feature: home, Property 4: Pomodoro initial remaining equals configured duration

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group;
import 'package:smart_learn/features/home/presentation/bloc/focus_cubit.dart';
import 'package:smart_learn/features/home/presentation/bloc/focus_state.dart';

void main() {
  // **Validates: Requirements 11.4, 11.8**
  group('Property 4: Pomodoro initial remaining equals configured duration',
      () {
    Glados(any.intInRange(1, 121)).test(
      'setPomodoroMinutes sets remaining, startPomodoro preserves it',
      (minutes) {
        final cubit = FocusCubit();
        addTearDown(cubit.close);

        cubit.setPomodoroMinutes(minutes);
        expect(
          cubit.state.remaining,
          equals(Duration(minutes: minutes)),
        );

        cubit.startPomodoro();
        expect(
          cubit.state.remaining,
          equals(Duration(minutes: minutes)),
        );
        expect(cubit.state.isRunning, isTrue);

        cubit.resetPomodoro();
      },
    );
  });

  group('FocusCubit - Stopwatch', () {
    late FocusCubit cubit;

    setUp(() {
      cubit = FocusCubit();
    });

    tearDown(() => cubit.close());

    test('startStopwatch sets isRunning to true', () {
      cubit.startStopwatch();
      expect(cubit.state.isRunning, isTrue);
      expect(cubit.state.elapsed, Duration.zero);
    });

    test('stopStopwatch sets isRunning to false', () {
      cubit.startStopwatch();
      cubit.stopStopwatch();
      expect(cubit.state.isRunning, isFalse);
    });

    test('resumeStopwatch sets isRunning to true', () {
      cubit.startStopwatch();
      cubit.stopStopwatch();
      cubit.resumeStopwatch();
      expect(cubit.state.isRunning, isTrue);
    });

    test('resetStopwatch sets elapsed to zero and isRunning to false', () {
      cubit.startStopwatch();
      cubit.resetStopwatch();
      expect(cubit.state.isRunning, isFalse);
      expect(cubit.state.elapsed, Duration.zero);
    });
  });

  group('FocusCubit - Pomodoro', () {
    late FocusCubit cubit;

    setUp(() {
      cubit = FocusCubit();
    });

    tearDown(() => cubit.close());

    test('setPomodoroMinutes updates remaining', () {
      cubit.setPomodoroMinutes(10);
      expect(cubit.state.pomodoroMinutes, 10);
      expect(cubit.state.remaining, const Duration(minutes: 10));
    });

    test('setPomodoroMinutes ignores values less than 1', () {
      cubit.setPomodoroMinutes(10);
      cubit.setPomodoroMinutes(0);
      expect(cubit.state.pomodoroMinutes, 10);
    });

    test('startPomodoro sets isRunning to true', () {
      cubit.setPomodoroMinutes(5);
      cubit.startPomodoro();
      expect(cubit.state.isRunning, isTrue);
      expect(cubit.state.remaining, const Duration(minutes: 5));
    });

    test('resetPomodoro resets remaining and stops', () {
      cubit.setPomodoroMinutes(10);
      cubit.startPomodoro();
      cubit.resetPomodoro();
      expect(cubit.state.isRunning, isFalse);
      expect(cubit.state.remaining, const Duration(minutes: 10));
      expect(cubit.state.pomodoroCompleted, isFalse);
    });
  });

  group('FocusCubit - switchMode', () {
    test('switchMode changes mode and cancels timers', () {
      final cubit = FocusCubit();
      addTearDown(cubit.close);

      cubit.startStopwatch();
      cubit.switchMode(FocusMode.pomodoro);
      expect(cubit.state.mode, FocusMode.pomodoro);
      expect(cubit.state.isRunning, isFalse);
    });
  });
}
