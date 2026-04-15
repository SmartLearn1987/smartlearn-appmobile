import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_learn/features/home/domain/entities/pictogram_entity.dart';
import 'package:smart_learn/features/pictogram_play/presentation/bloc/pictogram_play_bloc.dart';

void main() {
  const testQuestions = [
    PictogramEntity(
      id: '1',
      imageUrl: 'https://example.com/img1.png',
      answer: 'Cat',
      level: 'easy',
    ),
    PictogramEntity(
      id: '2',
      imageUrl: 'https://example.com/img2.png',
      answer: 'Dog',
      level: 'easy',
    ),
    PictogramEntity(
      id: '3',
      imageUrl: 'https://example.com/img3.png',
      answer: 'Bird',
      level: 'easy',
    ),
  ];

  const timeInMinutes = 2;

  group('PictogramPlayBloc', () {
    blocTest<PictogramPlayBloc, PictogramPlayState>(
      'StartGame emits PictogramPlayInProgress with '
      'currentIndex=0, correctCount=0, remainingSeconds=timeInMinutes*60',
      build: PictogramPlayBloc.new,
      act: (bloc) => bloc.add(
        const StartGame(
          questions: testQuestions,
          timeInMinutes: timeInMinutes,
        ),
      ),
      expect: () => [
        const PictogramPlayInProgress(
          questions: testQuestions,
          currentIndex: 0,
          correctCount: 0,
          remainingSeconds: timeInMinutes * 60,
        ),
      ],
      verify: (bloc) => bloc.close(),
    );

    blocTest<PictogramPlayBloc, PictogramPlayState>(
      'SubmitAnswer with correct answer emits state with '
      'correctCount+1 and lastAnswerResult=correct',
      build: PictogramPlayBloc.new,
      seed: () => const PictogramPlayInProgress(
        questions: testQuestions,
        currentIndex: 0,
        correctCount: 0,
        remainingSeconds: 120,
      ),
      act: (bloc) => bloc.add(const SubmitAnswer(answer: 'cat')),
      expect: () => [
        const PictogramPlayInProgress(
          questions: testQuestions,
          currentIndex: 0,
          correctCount: 1,
          remainingSeconds: 120,
          lastAnswerResult: AnswerResult.correct,
        ),
      ],
    );

    blocTest<PictogramPlayBloc, PictogramPlayState>(
      'SubmitAnswer with wrong answer emits state with '
      'same correctCount and lastAnswerResult=incorrect',
      build: PictogramPlayBloc.new,
      seed: () => const PictogramPlayInProgress(
        questions: testQuestions,
        currentIndex: 0,
        correctCount: 0,
        remainingSeconds: 120,
      ),
      act: (bloc) => bloc.add(const SubmitAnswer(answer: 'wrong')),
      expect: () => [
        const PictogramPlayInProgress(
          questions: testQuestions,
          currentIndex: 0,
          correctCount: 0,
          remainingSeconds: 120,
          lastAnswerResult: AnswerResult.incorrect,
        ),
      ],
    );

    blocTest<PictogramPlayBloc, PictogramPlayState>(
      'SkipQuestion emits state with currentIndex+1',
      build: PictogramPlayBloc.new,
      seed: () => const PictogramPlayInProgress(
        questions: testQuestions,
        currentIndex: 0,
        correctCount: 0,
        remainingSeconds: 120,
      ),
      act: (bloc) => bloc.add(const SkipQuestion()),
      expect: () => [
        const PictogramPlayInProgress(
          questions: testQuestions,
          currentIndex: 1,
          correctCount: 0,
          remainingSeconds: 120,
        ),
      ],
    );

    blocTest<PictogramPlayBloc, PictogramPlayState>(
      'TimerTick emits state with remainingSeconds-1',
      build: PictogramPlayBloc.new,
      seed: () => const PictogramPlayInProgress(
        questions: testQuestions,
        currentIndex: 0,
        correctCount: 0,
        remainingSeconds: 120,
      ),
      act: (bloc) => bloc.add(const TimerTick()),
      expect: () => [
        const PictogramPlayInProgress(
          questions: testQuestions,
          currentIndex: 0,
          correctCount: 0,
          remainingSeconds: 119,
        ),
      ],
    );

    blocTest<PictogramPlayBloc, PictogramPlayState>(
      'EndGame emits PictogramPlayFinished with correct '
      'correctCount, totalQuestions, elapsedSeconds',
      build: PictogramPlayBloc.new,
      act: (bloc) async {
        bloc.add(
          const StartGame(
            questions: testQuestions,
            timeInMinutes: timeInMinutes,
          ),
        );
        await Future<void>.delayed(Duration.zero);
        // Simulate some time passing via TimerTick
        bloc.add(const TimerTick());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const TimerTick());
        await Future<void>.delayed(Duration.zero);
        // Submit a correct answer
        bloc.add(const SubmitAnswer(answer: 'cat'));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const EndGame());
      },
      expect: () => [
        const PictogramPlayInProgress(
          questions: testQuestions,
          currentIndex: 0,
          correctCount: 0,
          remainingSeconds: 120,
        ),
        const PictogramPlayInProgress(
          questions: testQuestions,
          currentIndex: 0,
          correctCount: 0,
          remainingSeconds: 119,
        ),
        const PictogramPlayInProgress(
          questions: testQuestions,
          currentIndex: 0,
          correctCount: 0,
          remainingSeconds: 118,
        ),
        const PictogramPlayInProgress(
          questions: testQuestions,
          currentIndex: 0,
          correctCount: 1,
          remainingSeconds: 118,
          lastAnswerResult: AnswerResult.correct,
        ),
        const PictogramPlayFinished(
          correctCount: 1,
          totalQuestions: 3,
          elapsedSeconds: 2,
        ),
      ],
      verify: (bloc) => bloc.close(),
    );

    blocTest<PictogramPlayBloc, PictogramPlayState>(
      'Timer reaching 0 emits PictogramPlayFinished',
      build: PictogramPlayBloc.new,
      act: (bloc) async {
        bloc.add(
          const StartGame(
            questions: testQuestions,
            timeInMinutes: timeInMinutes,
          ),
        );
        await Future<void>.delayed(Duration.zero);
        // Fast-forward timer to remainingSeconds=1
        for (var i = 0; i < 119; i++) {
          bloc.add(const TimerTick());
          await Future<void>.delayed(Duration.zero);
        }
        // This tick brings remainingSeconds to 0 → triggers EndGame
        bloc.add(const TimerTick());
      },
      skip: 120, // Skip StartGame emit + 119 TimerTick emits
      expect: () => [
        // elapsedSeconds = totalSeconds(120) - remainingSeconds(1) = 119
        // because _onTimerTick dispatches EndGame without emitting
        // the decremented state when remainingSeconds reaches 0
        const PictogramPlayFinished(
          correctCount: 0,
          totalQuestions: 3,
          elapsedSeconds: 119,
        ),
      ],
      verify: (bloc) => bloc.close(),
    );
  });
}
