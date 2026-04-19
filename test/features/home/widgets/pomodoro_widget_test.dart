import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_learn/features/home/presentation/bloc/focus_cubit.dart';
import 'package:smart_learn/features/home/presentation/bloc/focus_state.dart';
import 'package:smart_learn/features/home/presentation/widgets/pomodoro_widget.dart';

class MockFocusCubit extends MockCubit<FocusState> implements FocusCubit {}

void main() {
  late MockFocusCubit mockFocusCubit;

  setUp(() {
    mockFocusCubit = MockFocusCubit();
  });

  Widget buildSubject() {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<FocusCubit>.value(
          value: mockFocusCubit,
          child: const PomodoroWidget(),
        ),
      ),
    );
  }

  group('PomodoroWidget', () {
    testWidgets('displays minute input field with default value "5"',
        (tester) async {
      when(() => mockFocusCubit.state).thenReturn(const FocusState(
        mode: FocusMode.pomodoro,
        remaining: Duration(minutes: 5),
        pomodoroMinutes: 5,
        isRunning: false,
        pomodoroCompleted: false,
      ));

      await tester.pumpWidget(buildSubject());

      // Verify the minute input label is present
      expect(find.text('Thời gian (phút):'), findsOneWidget);

      // Verify the TextField exists with default value "5"
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, '5');
    });

    testWidgets('"BẮT ĐẦU" button is present when not running',
        (tester) async {
      when(() => mockFocusCubit.state).thenReturn(const FocusState(
        mode: FocusMode.pomodoro,
        remaining: Duration(minutes: 5),
        pomodoroMinutes: 5,
        isRunning: false,
        pomodoroCompleted: false,
      ));

      await tester.pumpWidget(buildSubject());

      expect(find.text('BẮT ĐẦU'), findsOneWidget);
    });

    testWidgets('displays countdown in HH:MM:SS.ms format', (tester) async {
      when(() => mockFocusCubit.state).thenReturn(const FocusState(
        mode: FocusMode.pomodoro,
        remaining: Duration(minutes: 5),
        pomodoroMinutes: 5,
        isRunning: false,
        pomodoroCompleted: false,
      ));

      await tester.pumpWidget(buildSubject());

      // formatDuration(Duration(minutes: 5)) => "00:05:00.00"
      // The widget splits by ':' and displays parts separately
      expect(find.text('00'), findsWidgets); // hours and seconds
      expect(find.text('05'), findsOneWidget); // minutes
      expect(find.text('.00'), findsOneWidget); // centiseconds
    });

    testWidgets('"ĐẶT LẠI" button is present', (tester) async {
      when(() => mockFocusCubit.state).thenReturn(const FocusState(
        mode: FocusMode.pomodoro,
        remaining: Duration(minutes: 5),
        pomodoroMinutes: 5,
        isRunning: false,
        pomodoroCompleted: false,
      ));

      await tester.pumpWidget(buildSubject());

      expect(find.text('ĐẶT LẠI'), findsOneWidget);
    });

    testWidgets('tapping "BẮT ĐẦU" calls startPomodoro on cubit',
        (tester) async {
      when(() => mockFocusCubit.state).thenReturn(const FocusState(
        mode: FocusMode.pomodoro,
        remaining: Duration(minutes: 5),
        pomodoroMinutes: 5,
        isRunning: false,
        pomodoroCompleted: false,
      ));

      await tester.pumpWidget(buildSubject());

      await tester.tap(find.text('BẮT ĐẦU'));

      verify(() => mockFocusCubit.startPomodoro()).called(1);
    });

    testWidgets(
        'shows completion popup with "XUẤT SẮC!" when pomodoroCompleted transitions to true',
        (tester) async {
      final stateController = StreamController<FocusState>.broadcast();

      // Initial state: not completed
      when(() => mockFocusCubit.state).thenReturn(const FocusState(
        mode: FocusMode.pomodoro,
        remaining: Duration.zero,
        pomodoroMinutes: 5,
        isRunning: false,
        pomodoroCompleted: false,
      ));
      whenListen(
        mockFocusCubit,
        stateController.stream,
      );

      await tester.pumpWidget(buildSubject());

      // Emit completed state
      const completedState = FocusState(
        mode: FocusMode.pomodoro,
        remaining: Duration.zero,
        pomodoroMinutes: 5,
        isRunning: false,
        pomodoroCompleted: true,
      );
      when(() => mockFocusCubit.state).thenReturn(completedState);
      stateController.add(completedState);

      await tester.pumpAndSettle();

      // Verify the completion dialog is shown
      expect(find.text('XUẤT SẮC!'), findsOneWidget);
      expect(find.text('POMODORO đã hoàn thành'), findsOneWidget);
      expect(find.text('TIẾP TỤC'), findsOneWidget);

      await stateController.close();
    });

    testWidgets('"BẮT ĐẦU" button is hidden when running', (tester) async {
      when(() => mockFocusCubit.state).thenReturn(const FocusState(
        mode: FocusMode.pomodoro,
        remaining: Duration(minutes: 4, seconds: 30),
        pomodoroMinutes: 5,
        isRunning: true,
        pomodoroCompleted: false,
      ));

      await tester.pumpWidget(buildSubject());

      expect(find.text('BẮT ĐẦU'), findsNothing);
      // "ĐẶT LẠI" should still be visible
      expect(find.text('ĐẶT LẠI'), findsOneWidget);
    });

    testWidgets('minute input is hidden when running', (tester) async {
      when(() => mockFocusCubit.state).thenReturn(const FocusState(
        mode: FocusMode.pomodoro,
        remaining: Duration(minutes: 4, seconds: 30),
        pomodoroMinutes: 5,
        isRunning: true,
        pomodoroCompleted: false,
      ));

      await tester.pumpWidget(buildSubject());

      expect(find.text('Thời gian (phút):'), findsNothing);
      expect(find.byType(TextField), findsNothing);
    });
  });
}
