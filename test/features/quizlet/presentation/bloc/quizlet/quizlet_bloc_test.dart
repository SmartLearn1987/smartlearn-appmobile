import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/features/quizlet/domain/entities/quizlet_entity.dart';
import 'package:smart_learn/features/quizlet/domain/usecases/delete_quizlet_use_case.dart';
import 'package:smart_learn/features/quizlet/domain/usecases/get_quizlets_use_case.dart';
import 'package:smart_learn/features/quizlet/presentation/bloc/quizlet/quizlet_bloc.dart';

class MockGetQuizletsUseCase extends Mock implements GetQuizletsUseCase {}
class MockDeleteQuizletUseCase extends Mock implements DeleteQuizletUseCase {}

void main() {
  late MockGetQuizletsUseCase mockGetQuizletsUseCase;
  late MockDeleteQuizletUseCase mockDeleteQuizletUseCase;

  const testQuizlets = [
    QuizletEntity(
      id: '1',
      title: 'English Vocabulary',
      subjectName: 'English',
      educationLevel: 'Trung học cơ sở',
      isPublic: true,
      userId: 'user_1',
      termCount: 20,
      authorName: 'Teacher A',
      createdAt: '2024-01-01',
    ),
    QuizletEntity(
      id: '2',
      title: 'Math Formulas',
      subjectName: 'Math',
      educationLevel: 'Trung học Phổ Thông',
      isPublic: true,
      userId: 'user_2',
      termCount: 15,
      authorName: 'Teacher B',
      createdAt: '2024-01-02',
    ),
  ];

  setUp(() {
    mockGetQuizletsUseCase = MockGetQuizletsUseCase();
    mockDeleteQuizletUseCase = MockDeleteQuizletUseCase();
  });

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  group('QuizletBloc', () {
    blocTest<QuizletBloc, QuizletState>(
      'emits [QuizletLoading, QuizletLoaded] when LoadQuizlets succeeds',
      build: () {
        when(() => mockGetQuizletsUseCase(any()))
            .thenAnswer((_) async => const Right(testQuizlets));
        return QuizletBloc(mockGetQuizletsUseCase, mockDeleteQuizletUseCase);
      },
      act: (bloc) => bloc.add(const LoadQuizlets()),
      expect: () => [
        const QuizletLoading(),
        const QuizletLoaded(quizlets: testQuizlets),
      ],
    );

    blocTest<QuizletBloc, QuizletState>(
      'emits [QuizletLoading, QuizletError] when LoadQuizlets fails',
      build: () {
        when(() => mockGetQuizletsUseCase(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Server error')),
        );
        return QuizletBloc(mockGetQuizletsUseCase, mockDeleteQuizletUseCase);
      },
      act: (bloc) => bloc.add(const LoadQuizlets()),
      expect: () => [
        const QuizletLoading(),
        const QuizletError(message: 'Server error'),
      ],
    );

    blocTest<QuizletBloc, QuizletState>(
      'emits [QuizletLoading, QuizletLoaded] with empty list when API returns empty',
      build: () {
        when(() => mockGetQuizletsUseCase(any()))
            .thenAnswer((_) async => const Right([]));
        return QuizletBloc(mockGetQuizletsUseCase, mockDeleteQuizletUseCase);
      },
      act: (bloc) => bloc.add(const LoadQuizlets()),
      expect: () => [
        const QuizletLoading(),
        const QuizletLoaded(quizlets: []),
      ],
    );

    blocTest<QuizletBloc, QuizletState>(
      'QuizletLoaded contains the correct list of entities',
      build: () {
        when(() => mockGetQuizletsUseCase(any()))
            .thenAnswer((_) async => const Right(testQuizlets));
        return QuizletBloc(mockGetQuizletsUseCase, mockDeleteQuizletUseCase);
      },
      act: (bloc) => bloc.add(const LoadQuizlets()),
      verify: (bloc) {
        final state = bloc.state;
        expect(state, isA<QuizletLoaded>());
        final loaded = state as QuizletLoaded;
        expect(loaded.quizlets, equals(testQuizlets));
        expect(loaded.quizlets.length, 2);
        expect(loaded.quizlets[0].id, '1');
        expect(loaded.quizlets[0].title, 'English Vocabulary');
        expect(loaded.quizlets[1].id, '2');
        expect(loaded.quizlets[1].title, 'Math Formulas');
      },
    );

    blocTest<QuizletBloc, QuizletState>(
      'RefreshQuizlets calls use case and emits [QuizletLoading, QuizletLoaded]',
      build: () {
        when(() => mockGetQuizletsUseCase(any()))
            .thenAnswer((_) async => const Right(testQuizlets));
        return QuizletBloc(mockGetQuizletsUseCase, mockDeleteQuizletUseCase);
      },
      act: (bloc) => bloc.add(const RefreshQuizlets()),
      expect: () => [
        const QuizletLoading(),
        const QuizletLoaded(quizlets: testQuizlets),
      ],
      verify: (_) {
        verify(() => mockGetQuizletsUseCase(any())).called(1);
      },
    );

    blocTest<QuizletBloc, QuizletState>(
      'RefreshQuizlets emits [QuizletLoading, QuizletError] when use case fails',
      build: () {
        when(() => mockGetQuizletsUseCase(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Network error')),
        );
        return QuizletBloc(mockGetQuizletsUseCase, mockDeleteQuizletUseCase);
      },
      act: (bloc) => bloc.add(const RefreshQuizlets()),
      expect: () => [
        const QuizletLoading(),
        const QuizletError(message: 'Network error'),
      ],
    );
  });
}
