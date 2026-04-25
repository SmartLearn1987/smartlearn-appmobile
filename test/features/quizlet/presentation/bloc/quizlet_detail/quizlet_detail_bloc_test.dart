import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/features/quizlet/domain/entities/quizlet_detail_entity.dart';
import 'package:smart_learn/features/quizlet/domain/entities/quizlet_term_entity.dart';
import 'package:smart_learn/features/quizlet/domain/usecases/get_quizlet_detail_use_case.dart';
import 'package:smart_learn/features/quizlet/presentation/bloc/quizlet_detail/quizlet_detail_bloc.dart';

class MockGetQuizletDetailUseCase extends Mock
    implements GetQuizletDetailUseCase {}

void main() {
  late MockGetQuizletDetailUseCase mockGetQuizletDetailUseCase;

  const testTerms = [
    QuizletTermEntity(
      id: 't1',
      term: 'Hello',
      definition: 'Xin chào',
      sortOrder: 0,
    ),
    QuizletTermEntity(
      id: 't2',
      term: 'Goodbye',
      definition: 'Tạm biệt',
      sortOrder: 1,
    ),
    QuizletTermEntity(
      id: 't3',
      term: 'Thank you',
      definition: 'Cảm ơn',
      sortOrder: 2,
    ),
  ];

  const testDetail = QuizletDetailEntity(
    id: 'q1',
    title: 'English Basics',
    description: 'Basic English vocabulary',
    subjectName: 'English',
    terms: testTerms,
  );

  setUp(() {
    mockGetQuizletDetailUseCase = MockGetQuizletDetailUseCase();
  });

  setUpAll(() {
    registerFallbackValue('');
  });

  group('QuizletDetailBloc', () {
    group('LoadQuizletDetail', () {
      blocTest<QuizletDetailBloc, QuizletDetailState>(
        'emits [Loading, Loaded] when LoadQuizletDetail succeeds',
        build: () {
          when(() => mockGetQuizletDetailUseCase(any()))
              .thenAnswer((_) async => const Right(testDetail));
          return QuizletDetailBloc(mockGetQuizletDetailUseCase);
        },
        act: (bloc) =>
            bloc.add(const LoadQuizletDetail(quizletId: 'q1')),
        expect: () => [
          const QuizletDetailLoading(),
          const QuizletDetailLoaded(
            detail: testDetail,
            currentIndex: 0,
            isFlipped: false,
          ),
        ],
      );

      blocTest<QuizletDetailBloc, QuizletDetailState>(
        'emits [Loading, Error] when LoadQuizletDetail fails',
        build: () {
          when(() => mockGetQuizletDetailUseCase(any())).thenAnswer(
            (_) async =>
                const Left(ServerFailure(message: 'Server error')),
          );
          return QuizletDetailBloc(mockGetQuizletDetailUseCase);
        },
        act: (bloc) =>
            bloc.add(const LoadQuizletDetail(quizletId: 'q1')),
        expect: () => [
          const QuizletDetailLoading(),
          const QuizletDetailError(message: 'Server error'),
        ],
      );
    });

    group('FlipCard', () {
      blocTest<QuizletDetailBloc, QuizletDetailState>(
        'toggles isFlipped from false to true',
        build: () {
          when(() => mockGetQuizletDetailUseCase(any()))
              .thenAnswer((_) async => const Right(testDetail));
          return QuizletDetailBloc(mockGetQuizletDetailUseCase);
        },
        seed: () => const QuizletDetailLoaded(
          detail: testDetail,
          currentIndex: 0,
          isFlipped: false,
        ),
        act: (bloc) => bloc.add(const FlipCard()),
        expect: () => [
          const QuizletDetailLoaded(
            detail: testDetail,
            currentIndex: 0,
            isFlipped: true,
          ),
        ],
      );

      blocTest<QuizletDetailBloc, QuizletDetailState>(
        'toggles isFlipped from true to false',
        build: () {
          when(() => mockGetQuizletDetailUseCase(any()))
              .thenAnswer((_) async => const Right(testDetail));
          return QuizletDetailBloc(mockGetQuizletDetailUseCase);
        },
        seed: () => const QuizletDetailLoaded(
          detail: testDetail,
          currentIndex: 0,
          isFlipped: true,
        ),
        act: (bloc) => bloc.add(const FlipCard()),
        expect: () => [
          const QuizletDetailLoaded(
            detail: testDetail,
            currentIndex: 0,
            isFlipped: false,
          ),
        ],
      );
    });

    group('NextCard', () {
      blocTest<QuizletDetailBloc, QuizletDetailState>(
        'increments currentIndex when not at last card',
        build: () {
          when(() => mockGetQuizletDetailUseCase(any()))
              .thenAnswer((_) async => const Right(testDetail));
          return QuizletDetailBloc(mockGetQuizletDetailUseCase);
        },
        seed: () => const QuizletDetailLoaded(
          detail: testDetail,
          currentIndex: 0,
          isFlipped: false,
        ),
        act: (bloc) => bloc.add(const NextCard()),
        expect: () => [
          const QuizletDetailLoaded(
            detail: testDetail,
            currentIndex: 1,
            isFlipped: false,
          ),
        ],
      );

      blocTest<QuizletDetailBloc, QuizletDetailState>(
        'does not change state when at last card',
        build: () {
          when(() => mockGetQuizletDetailUseCase(any()))
              .thenAnswer((_) async => const Right(testDetail));
          return QuizletDetailBloc(mockGetQuizletDetailUseCase);
        },
        seed: () => const QuizletDetailLoaded(
          detail: testDetail,
          currentIndex: 2, // last card (3 terms, index 0-2)
          isFlipped: false,
        ),
        act: (bloc) => bloc.add(const NextCard()),
        expect: () => [],
      );

      blocTest<QuizletDetailBloc, QuizletDetailState>(
        'resets isFlipped to false when moving to next card',
        build: () {
          when(() => mockGetQuizletDetailUseCase(any()))
              .thenAnswer((_) async => const Right(testDetail));
          return QuizletDetailBloc(mockGetQuizletDetailUseCase);
        },
        seed: () => const QuizletDetailLoaded(
          detail: testDetail,
          currentIndex: 0,
          isFlipped: true,
        ),
        act: (bloc) => bloc.add(const NextCard()),
        expect: () => [
          const QuizletDetailLoaded(
            detail: testDetail,
            currentIndex: 1,
            isFlipped: false,
          ),
        ],
      );
    });

    group('PreviousCard', () {
      blocTest<QuizletDetailBloc, QuizletDetailState>(
        'decrements currentIndex when not at first card',
        build: () {
          when(() => mockGetQuizletDetailUseCase(any()))
              .thenAnswer((_) async => const Right(testDetail));
          return QuizletDetailBloc(mockGetQuizletDetailUseCase);
        },
        seed: () => const QuizletDetailLoaded(
          detail: testDetail,
          currentIndex: 2,
          isFlipped: false,
        ),
        act: (bloc) => bloc.add(const PreviousCard()),
        expect: () => [
          const QuizletDetailLoaded(
            detail: testDetail,
            currentIndex: 1,
            isFlipped: false,
          ),
        ],
      );

      blocTest<QuizletDetailBloc, QuizletDetailState>(
        'does not change state when at first card',
        build: () {
          when(() => mockGetQuizletDetailUseCase(any()))
              .thenAnswer((_) async => const Right(testDetail));
          return QuizletDetailBloc(mockGetQuizletDetailUseCase);
        },
        seed: () => const QuizletDetailLoaded(
          detail: testDetail,
          currentIndex: 0,
          isFlipped: false,
        ),
        act: (bloc) => bloc.add(const PreviousCard()),
        expect: () => [],
      );

      blocTest<QuizletDetailBloc, QuizletDetailState>(
        'resets isFlipped to false when moving to previous card',
        build: () {
          when(() => mockGetQuizletDetailUseCase(any()))
              .thenAnswer((_) async => const Right(testDetail));
          return QuizletDetailBloc(mockGetQuizletDetailUseCase);
        },
        seed: () => const QuizletDetailLoaded(
          detail: testDetail,
          currentIndex: 2,
          isFlipped: true,
        ),
        act: (bloc) => bloc.add(const PreviousCard()),
        expect: () => [
          const QuizletDetailLoaded(
            detail: testDetail,
            currentIndex: 1,
            isFlipped: false,
          ),
        ],
      );
    });
  });
}
