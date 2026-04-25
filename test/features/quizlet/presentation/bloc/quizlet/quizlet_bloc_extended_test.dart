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
import 'package:smart_learn/features/quizlet/presentation/helpers/quizlet_filter_helper.dart';

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
      educationLevel: 'Tiểu học',
      isPublic: true,
      userId: 'user_2',
      termCount: 15,
      authorName: 'Teacher B',
      createdAt: '2024-01-02',
    ),
    QuizletEntity(
      id: '3',
      title: 'Private Set',
      subjectName: 'Math',
      educationLevel: 'Tiểu học',
      isPublic: false,
      userId: 'user_1',
      termCount: 10,
      authorName: 'Teacher C',
      createdAt: '2024-01-03',
    ),
  ];

  setUp(() {
    mockGetQuizletsUseCase = MockGetQuizletsUseCase();
    mockDeleteQuizletUseCase = MockDeleteQuizletUseCase();
  });

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  QuizletBloc buildBloc() => QuizletBloc(
        mockGetQuizletsUseCase,
        mockDeleteQuizletUseCase,
      );

  group('QuizletBloc extended', () {
    blocTest<QuizletBloc, QuizletState>(
      'LoadQuizlets defaults to community mode and filters results',
      build: () {
        when(() => mockGetQuizletsUseCase(any()))
            .thenAnswer((_) async => const Right(testQuizlets));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadQuizlets()),
      expect: () => [
        const QuizletLoading(),
        QuizletLoaded(
          allQuizlets: testQuizlets,
          filteredQuizlets: [testQuizlets[0], testQuizlets[1]],
          viewMode: ViewMode.community,
          searchQuery: '',
        ),
      ],
    );

    blocTest<QuizletBloc, QuizletState>(
      'ChangeViewMode updates filtered list',
      build: () => buildBloc(),
      seed: () => QuizletLoaded(
        allQuizlets: testQuizlets,
        filteredQuizlets: [testQuizlets[0], testQuizlets[1]],
        viewMode: ViewMode.community,
        searchQuery: '',
      ),
      act: (bloc) => bloc.add(const ChangeViewMode(ViewMode.personal)),
      expect: () => [
        QuizletLoaded(
          allQuizlets: testQuizlets,
          filteredQuizlets: [testQuizlets[0], testQuizlets[2]],
          viewMode: ViewMode.personal,
          searchQuery: '',
        ),
      ],
    );

    blocTest<QuizletBloc, QuizletState>(
      'SearchQuizlets filters within current mode',
      build: () => buildBloc(),
      seed: () => QuizletLoaded(
        allQuizlets: testQuizlets,
        filteredQuizlets: [testQuizlets[0], testQuizlets[2]],
        viewMode: ViewMode.personal,
        searchQuery: '',
      ),
      act: (bloc) => bloc.add(const SearchQuizlets('english')),
      expect: () => [
        QuizletLoaded(
          allQuizlets: testQuizlets,
          filteredQuizlets: [testQuizlets[0]],
          viewMode: ViewMode.personal,
          searchQuery: 'english',
        ),
      ],
    );

    blocTest<QuizletBloc, QuizletState>(
      'DeleteQuizlet removes item when successful',
      build: () {
        when(() => mockDeleteQuizletUseCase(any()))
            .thenAnswer((_) async => const Right(null));
        return buildBloc();
      },
      seed: () => QuizletLoaded(
        allQuizlets: testQuizlets,
        filteredQuizlets: [testQuizlets[0], testQuizlets[2]],
        viewMode: ViewMode.personal,
        searchQuery: '',
      ),
      act: (bloc) => bloc.add(const DeleteQuizlet('2')),
      expect: () => [
        QuizletLoaded(
          allQuizlets: [testQuizlets[0], testQuizlets[2]],
          filteredQuizlets: [testQuizlets[0], testQuizlets[2]],
          viewMode: ViewMode.personal,
          searchQuery: '',
        ),
      ],
    );

    blocTest<QuizletBloc, QuizletState>(
      'DeleteQuizlet emits error when use case fails',
      build: () {
        when(() => mockDeleteQuizletUseCase(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Không thể xóa')),
        );
        return buildBloc();
      },
      seed: () => QuizletLoaded(
        allQuizlets: testQuizlets,
        filteredQuizlets: [testQuizlets[0], testQuizlets[2]],
        viewMode: ViewMode.personal,
        searchQuery: '',
      ),
      act: (bloc) => bloc.add(const DeleteQuizlet('2')),
      expect: () => [
        const QuizletError(message: 'Không thể xóa'),
      ],
    );
  });
}
