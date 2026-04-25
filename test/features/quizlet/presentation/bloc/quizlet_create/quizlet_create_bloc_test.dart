import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/features/home/domain/entities/subject_entity.dart';
import 'package:smart_learn/features/quizlet/domain/entities/quizlet_detail_entity.dart';
import 'package:smart_learn/features/quizlet/domain/entities/quizlet_term_entity.dart';
import 'package:smart_learn/features/quizlet/domain/usecases/create_quizlet_use_case.dart';
import 'package:smart_learn/features/quizlet/domain/usecases/get_quizlet_detail_use_case.dart';
import 'package:smart_learn/features/quizlet/domain/usecases/params/create_quizlet_params.dart';
import 'package:smart_learn/features/quizlet/domain/usecases/params/update_quizlet_params.dart';
import 'package:smart_learn/features/quizlet/domain/usecases/update_quizlet_use_case.dart';
import 'package:smart_learn/features/quizlet/presentation/bloc/quizlet_create/quizlet_create_bloc.dart';
import 'package:smart_learn/features/quizlet/presentation/helpers/csv_import_helper.dart';
import 'package:smart_learn/features/subjects/domain/usecases/get_subjects_use_case.dart';

class MockCreateQuizletUseCase extends Mock implements CreateQuizletUseCase {}

class MockUpdateQuizletUseCase extends Mock implements UpdateQuizletUseCase {}

class MockGetQuizletDetailUseCase extends Mock
    implements GetQuizletDetailUseCase {}

class MockGetSubjectsUseCase extends Mock implements GetSubjectsUseCase {}

void main() {
  late MockCreateQuizletUseCase mockCreateQuizletUseCase;
  late MockUpdateQuizletUseCase mockUpdateQuizletUseCase;
  late MockGetQuizletDetailUseCase mockGetQuizletDetailUseCase;
  late MockGetSubjectsUseCase mockGetSubjectsUseCase;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(
      const CreateQuizletParams(
        title: 't',
        isPublic: true,
        createdBy: 'u',
        terms: [],
      ),
    );
    registerFallbackValue(
      const UpdateQuizletParams(
        id: 'id',
        title: 't',
        isPublic: true,
        terms: [],
      ),
    );
  });

  setUp(() {
    mockCreateQuizletUseCase = MockCreateQuizletUseCase();
    mockUpdateQuizletUseCase = MockUpdateQuizletUseCase();
    mockGetQuizletDetailUseCase = MockGetQuizletDetailUseCase();
    mockGetSubjectsUseCase = MockGetSubjectsUseCase();
  });

  QuizletCreateBloc buildBloc() => QuizletCreateBloc(
        mockCreateQuizletUseCase,
        mockUpdateQuizletUseCase,
        mockGetQuizletDetailUseCase,
        mockGetSubjectsUseCase,
      );

  group('QuizletCreateBloc', () {
    test('initial state has 2 empty cards and isEditMode false', () {
      final state = buildBloc().state;
      expect(state.isEditMode, isFalse);
      expect(state.cards.length, 2);
      expect(state.cards, const [CardFormData.empty(), CardFormData.empty()]);
    });

    blocTest<QuizletCreateBloc, QuizletCreateState>(
      'LoadSubjects loads subjects on success',
      build: () {
        when(() => mockGetSubjectsUseCase(any())).thenAnswer(
          (_) async => const Right([
            SubjectEntity(
              id: 's1',
              name: 'Toan',
              sortOrder: 1,
              curriculumCount: 0,
            ),
          ]),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadSubjects()),
      expect: () => [
        const QuizletCreateState(
          subjects: [
            SubjectEntity(
              id: 's1',
              name: 'Toan',
              sortOrder: 1,
              curriculumCount: 0,
            ),
          ],
        ),
      ],
    );

    blocTest<QuizletCreateBloc, QuizletCreateState>(
      'LoadQuizletForEdit pre-populates edit state',
      build: () {
        when(() => mockGetQuizletDetailUseCase(any())).thenAnswer(
          (_) async => Right(
            QuizletDetailEntity(
              id: 'q1',
              title: 'Title',
              description: 'Desc',
              subjectName: 'Toan',
              subjectId: 's1',
              grade: '7',
              educationLevel: 'Tiểu học',
              isPublic: false,
              userId: 'u1',
              terms: const [
                QuizletTermEntity(
                  id: 't1',
                  term: 'Hello',
                  definition: 'Xin chao',
                  sortOrder: 0,
                ),
              ],
            ),
          ),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadQuizletForEdit('q1')),
      expect: () => [
        const QuizletCreateState(isLoadingDetail: true),
        const QuizletCreateState(
          isEditMode: true,
          quizletId: 'q1',
          title: 'Title',
          description: 'Desc',
          isPublic: false,
          selectedSubjectId: 's1',
          educationLevel: 'Tiểu học',
          grade: '7',
          cards: [CardFormData(term: 'Hello', definition: 'Xin chao')],
        ),
      ],
    );

    blocTest<QuizletCreateBloc, QuizletCreateState>(
      'AddCard then RemoveCard updates card list with minimum threshold',
      build: () => buildBloc(),
      act: (bloc) {
        bloc
          ..add(const AddCard())
          ..add(const RemoveCard(0))
          ..add(const RemoveCard(0));
      },
      expect: () => [
        const QuizletCreateState(
          cards: [
            CardFormData.empty(),
            CardFormData.empty(),
            CardFormData.empty(),
          ],
        ),
        const QuizletCreateState(
          cards: [CardFormData.empty(), CardFormData.empty()],
        ),
      ],
    );

    blocTest<QuizletCreateBloc, QuizletCreateState>(
      'ImportCards fills empty cards first',
      build: () => buildBloc(),
      act: (bloc) => bloc.add(const ImportCards('a,b\nc,d')),
      expect: () => [
        const QuizletCreateState(
          cards: [
            CardFormData(term: 'a', definition: 'b'),
            CardFormData(term: 'c', definition: 'd'),
          ],
        ),
      ],
    );

    blocTest<QuizletCreateBloc, QuizletCreateState>(
      'SubmitQuizlet validates title and cards',
      build: () => buildBloc(),
      act: (bloc) => bloc.add(const SubmitQuizlet()),
      expect: () => [
        const QuizletCreateState(errorMessage: 'Vui lòng nhập tiêu đề'),
      ],
    );

    blocTest<QuizletCreateBloc, QuizletCreateState>(
      'SubmitQuizlet create flow success',
      build: () {
        when(() => mockCreateQuizletUseCase(any()))
            .thenAnswer((_) async => const Right(null));
        return buildBloc();
      },
      seed: () => const QuizletCreateState(
        title: 'New quizlet',
        cards: [CardFormData(term: 'Hello', definition: 'Xin chao')],
      ),
      act: (bloc) => bloc.add(const SubmitQuizlet()),
      expect: () => [
        const QuizletCreateState(
          title: 'New quizlet',
          cards: [CardFormData(term: 'Hello', definition: 'Xin chao')],
          isSubmitting: true,
        ),
        const QuizletCreateState(
          title: 'New quizlet',
          cards: [CardFormData(term: 'Hello', definition: 'Xin chao')],
          isSubmitting: false,
          isSuccess: true,
        ),
      ],
    );

    blocTest<QuizletCreateBloc, QuizletCreateState>(
      'SubmitQuizlet update flow failure emits error',
      build: () {
        when(() => mockUpdateQuizletUseCase(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Update failed')),
        );
        return buildBloc();
      },
      seed: () => const QuizletCreateState(
        isEditMode: true,
        quizletId: 'q1',
        title: 'Updated',
        cards: [CardFormData(term: 'Hello', definition: 'Xin chao')],
      ),
      act: (bloc) => bloc.add(const SubmitQuizlet()),
      expect: () => [
        const QuizletCreateState(
          isEditMode: true,
          quizletId: 'q1',
          title: 'Updated',
          cards: [CardFormData(term: 'Hello', definition: 'Xin chao')],
          isSubmitting: true,
        ),
        const QuizletCreateState(
          isEditMode: true,
          quizletId: 'q1',
          title: 'Updated',
          cards: [CardFormData(term: 'Hello', definition: 'Xin chao')],
          isSubmitting: false,
          errorMessage: 'Update failed',
        ),
      ],
    );
  });
}
