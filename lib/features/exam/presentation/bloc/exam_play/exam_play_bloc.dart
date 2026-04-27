import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/exam_detail_entity.dart';
import '../../../domain/entities/exam_option_entity.dart';
import '../../../domain/entities/exam_question_result.dart';
import '../../../domain/usecases/submit_exam_result_use_case.dart';

part 'exam_play_event.dart';
part 'exam_play_state.dart';

@injectable
class ExamPlayBloc extends Bloc<ExamPlayEvent, ExamPlayState> {
  final SubmitExamResultUseCase _submitExamResult;
  StreamSubscription<void>? _timerSubscription;

  ExamPlayBloc(this._submitExamResult) : super(const ExamPlayInitial()) {
    on<StartExam>(_onStartExam);
    on<SetAnswer>(_onSetAnswer);
    on<NextQuestion>(_onNextQuestion);
    on<PreviousQuestion>(_onPreviousQuestion);
    on<TimerTick>(_onTimerTick);
    on<SubmitExam>(_onSubmitExam);
  }

  void _onStartExam(StartExam event, Emitter<ExamPlayState> emit) {
    _timerSubscription?.cancel();
    emit(
      ExamPlayInProgress(
        detail: event.detail,
        currentQuestionIndex: 0,
        selectedAnswers: const {},
        timeRemaining: event.durationInMinutes * 60,
        totalTime: event.durationInMinutes * 60,
      ),
    );
    _timerSubscription = Stream.periodic(
      const Duration(seconds: 1),
    ).listen((_) => add(const TimerTick()));
  }

  void _onSetAnswer(SetAnswer event, Emitter<ExamPlayState> emit) {
    final currentState = state;
    if (currentState is ExamPlayInProgress) {
      final updatedAnswers = {
        ...currentState.selectedAnswers,
        event.questionId: event.answer,
      };
      emit(
        ExamPlayInProgress(
          detail: currentState.detail,
          currentQuestionIndex: currentState.currentQuestionIndex,
          selectedAnswers: updatedAnswers,
          timeRemaining: currentState.timeRemaining,
          totalTime: currentState.totalTime,
        ),
      );
    }
  }

  void _onNextQuestion(NextQuestion event, Emitter<ExamPlayState> emit) {
    final currentState = state;
    if (currentState is ExamPlayInProgress) {
      if (currentState.currentQuestionIndex <
          currentState.detail.questions.length - 1) {
        emit(
          ExamPlayInProgress(
            detail: currentState.detail,
            currentQuestionIndex: currentState.currentQuestionIndex + 1,
            selectedAnswers: currentState.selectedAnswers,
            timeRemaining: currentState.timeRemaining,
            totalTime: currentState.totalTime,
          ),
        );
      }
    }
  }

  void _onPreviousQuestion(
    PreviousQuestion event,
    Emitter<ExamPlayState> emit,
  ) {
    final currentState = state;
    if (currentState is ExamPlayInProgress) {
      if (currentState.currentQuestionIndex > 0) {
        emit(
          ExamPlayInProgress(
            detail: currentState.detail,
            currentQuestionIndex: currentState.currentQuestionIndex - 1,
            selectedAnswers: currentState.selectedAnswers,
            timeRemaining: currentState.timeRemaining,
            totalTime: currentState.totalTime,
          ),
        );
      }
    }
  }

  void _onTimerTick(TimerTick event, Emitter<ExamPlayState> emit) {
    final currentState = state;
    if (currentState is ExamPlayInProgress) {
      if (currentState.timeRemaining <= 1) {
        _timerSubscription?.cancel();
        add(const SubmitExam());
      } else {
        emit(
          ExamPlayInProgress(
            detail: currentState.detail,
            currentQuestionIndex: currentState.currentQuestionIndex,
            selectedAnswers: currentState.selectedAnswers,
            timeRemaining: currentState.timeRemaining - 1,
            totalTime: currentState.totalTime,
          ),
        );
      }
    }
  }

  Future<void> _onSubmitExam(
    SubmitExam event,
    Emitter<ExamPlayState> emit,
  ) async {
    final currentState = state;
    if (currentState is ExamPlayInProgress) {
      _timerSubscription?.cancel();
      final inProgressState = currentState;
      emit(const ExamPlaySubmitting());

      final detail = inProgressState.detail;
      final selectedAnswers = inProgressState.selectedAnswers;

      final questionResults = <ExamQuestionResult>[];
      var correctCount = 0;

      for (final question in detail.questions) {
        final correctOptions = question.options
            .where((option) => option.isCorrect)
            .toList();
        final selectedAnswer = selectedAnswers[question.id];
        String? selectedOptionId;
        List<String> selectedOptionIds = const [];
        String? selectedTextAnswer;
        String? correctTextAnswer;
        String correctOptionId = '';
        bool isCorrect = false;

        switch (question.type) {
          case 'single':
            final correctOption = correctOptions.isNotEmpty
                ? correctOptions.first
                : const ExamOptionEntity(
                    id: '',
                    content: '',
                    isCorrect: false,
                    sortOrder: 0,
                  );
            selectedOptionId = selectedAnswer as String?;
            correctOptionId = correctOption.id;
            isCorrect =
                selectedOptionId == correctOption.id &&
                correctOption.id.isNotEmpty;
            break;
          case 'multiple':
            final selectedIds = (selectedAnswer is List)
                ? selectedAnswer.cast<String>().toSet()
                : <String>{};
            final correctIds = correctOptions
                .map((option) => option.id)
                .toSet();
            selectedOptionIds = selectedIds.toList();
            isCorrect =
                selectedIds.isNotEmpty &&
                selectedIds.length == correctIds.length &&
                selectedIds.containsAll(correctIds);
            break;
          case 'text':
          case 'ordering':
            final expected = correctOptions.isNotEmpty
                ? correctOptions.first.content
                : '';
            final actual = selectedAnswer is String ? selectedAnswer : '';
            selectedTextAnswer = actual;
            correctTextAnswer = expected;
            isCorrect =
                _normalizeTextAnswer(actual) ==
                    _normalizeTextAnswer(expected) &&
                actual.trim().isNotEmpty;
            break;
          default:
            break;
        }

        if (isCorrect) {
          correctCount++;
        }

        questionResults.add(
          ExamQuestionResult(
            questionId: question.id,
            questionContent: question.content,
            questionType: question.type,
            selectedOptionId: selectedOptionId,
            selectedOptionIds: selectedOptionIds,
            selectedTextAnswer: selectedTextAnswer,
            correctTextAnswer: correctTextAnswer,
            correctOptionId: correctOptionId,
            isCorrect: isCorrect,
            options: question.options,
          ),
        );
      }

      final totalCount = detail.questions.length;
      final scorePercent = totalCount > 0
          ? (correctCount / totalCount) * 100
          : 0.0;
      final timeTaken =
          inProgressState.totalTime - inProgressState.timeRemaining;

      final result = await _submitExamResult(
        SubmitExamResultParams(
          examId: detail.id,
          score: scorePercent,
          timeTaken: timeTaken,
        ),
      );

      result.fold(
        (failure) => emit(
          ExamPlayCompleted(
            correctCount: correctCount,
            totalCount: totalCount,
            scorePercent: scorePercent,
            timeTaken: timeTaken,
            questionResults: questionResults,
            errorMessage: failure.message,
          ),
        ),
        (_) => emit(
          ExamPlayCompleted(
            correctCount: correctCount,
            totalCount: totalCount,
            scorePercent: scorePercent,
            timeTaken: timeTaken,
            questionResults: questionResults,
          ),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _timerSubscription?.cancel();
    return super.close();
  }
}

String _normalizeTextAnswer(String value) =>
    value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
