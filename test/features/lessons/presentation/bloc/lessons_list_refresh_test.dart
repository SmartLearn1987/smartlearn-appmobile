import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_learn/features/lessons/domain/entities/lesson_entity.dart';
import 'package:smart_learn/features/lessons/domain/entities/lesson_progress.dart';
import 'package:smart_learn/features/lessons/domain/usecases/create_lesson_use_case.dart';
import 'package:smart_learn/features/lessons/domain/usecases/delete_lesson_image_use_case.dart';
import 'package:smart_learn/features/lessons/domain/usecases/delete_lesson_use_case.dart';
import 'package:smart_learn/features/lessons/domain/usecases/get_lesson_progress_use_case.dart';
import 'package:smart_learn/features/lessons/domain/usecases/get_lessons_use_case.dart';
import 'package:smart_learn/features/lessons/domain/usecases/update_lesson_use_case.dart';
import 'package:smart_learn/features/lessons/domain/usecases/update_quiz_flashcards_use_case.dart';
import 'package:smart_learn/features/lessons/domain/usecases/upload_lesson_images_use_case.dart';
import 'package:smart_learn/features/lessons/presentation/bloc/lessons_list/lessons_list_bloc.dart';

class MockGetLessonsUseCase extends Mock implements GetLessonsUseCase {}

class MockGetLessonProgressUseCase extends Mock
    implements GetLessonProgressUseCase {}

class MockDeleteLessonUseCase extends Mock implements DeleteLessonUseCase {}

class MockCreateLessonUseCase extends Mock implements CreateLessonUseCase {}

class MockUpdateLessonUseCase extends Mock implements UpdateLessonUseCase {}

class MockUpdateQuizFlashcardsUseCase extends Mock
    implements UpdateQuizFlashcardsUseCase {}

class MockUploadLessonImagesUseCase extends Mock
    implements UploadLessonImagesUseCase {}

class MockDeleteLessonImageUseCase extends Mock
    implements DeleteLessonImageUseCase {}

void main() {
  late MockGetLessonsUseCase mockGetLessons;
  late MockGetLessonProgressUseCase mockGetProgress;
  late MockDeleteLessonUseCase mockDeleteLesson;
  late MockCreateLessonUseCase mockCreateLesson;
  late MockUpdateLessonUseCase mockUpdateLesson;
  late MockUpdateQuizFlashcardsUseCase mockUpdateQuizFlashcards;
  late MockUploadLessonImagesUseCase mockUploadImages;
  late MockDeleteLessonImageUseCase mockDeleteImage;

  const curriculumId = 'curriculum_1';
  const studentId = 'student_1';

  final testLessons = [
    const LessonEntity(
      id: 'lesson_1',
      curriculumId: curriculumId,
      title: 'Lesson 1',
      content: [],
      keyPoints: [],
      vocabulary: [],
      quiz: [],
      flashcards: [],
      sortOrder: 1,
    ),
    const LessonEntity(
      id: 'lesson_2',
      curriculumId: curriculumId,
      title: 'Lesson 2',
      content: [],
      keyPoints: [],
      vocabulary: [],
      quiz: [],
      flashcards: [],
      sortOrder: 2,
    ),
  ];

  setUp(() {
    mockGetLessons = MockGetLessonsUseCase();
    mockGetProgress = MockGetLessonProgressUseCase();
    mockDeleteLesson = MockDeleteLessonUseCase();
    mockCreateLesson = MockCreateLessonUseCase();
    mockUpdateLesson = MockUpdateLessonUseCase();
    mockUpdateQuizFlashcards = MockUpdateQuizFlashcardsUseCase();
    mockUploadImages = MockUploadLessonImagesUseCase();
    mockDeleteImage = MockDeleteLessonImageUseCase();
  });

  LessonsListBloc buildBloc() => LessonsListBloc(
        mockGetLessons,
        mockGetProgress,
        mockDeleteLesson,
        mockCreateLesson,
        mockUpdateLesson,
        mockUpdateQuizFlashcards,
        mockUploadImages,
        mockDeleteImage,
      );

  group('Progress refresh on navigation back', () {
    blocTest<LessonsListBloc, LessonsListState>(
      'LessonsLoadRequested fetches fresh lessons and progress data, '
      'ensuring Review tab reflects updated completion badges',
      build: () {
        when(() => mockGetLessons(curriculumId))
            .thenAnswer((_) async => Right(testLessons));
        when(() => mockGetProgress(studentId)).thenAnswer(
          (_) async => Right([
            LessonProgress(
              id: 'prog_1',
              studentId: studentId,
              lessonId: 'lesson_1',
              completed: true,
              completedAt: DateTime(2024, 1, 1),
            ),
          ]),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LessonsLoadRequested(
        curriculumId: curriculumId,
        studentId: studentId,
      )),
      expect: () => [
        const LessonsListLoading(),
        LessonsListLoaded(
          lessons: testLessons,
          progressMap: const {'lesson_1': true},
        ),
      ],
      verify: (_) {
        verify(() => mockGetLessons(curriculumId)).called(1);
        verify(() => mockGetProgress(studentId)).called(1);
      },
    );

    blocTest<LessonsListBloc, LessonsListState>(
      'LessonsRefreshRequested re-fetches lessons and progress '
      'using stored curriculum and student IDs',
      build: () {
        when(() => mockGetLessons(curriculumId))
            .thenAnswer((_) async => Right(testLessons));
        // First call: lesson_1 not completed
        // Second call (refresh): lesson_1 completed
        var callCount = 0;
        when(() => mockGetProgress(studentId)).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) {
            return const Right(<LessonProgress>[]);
          }
          return Right([
            LessonProgress(
              id: 'prog_1',
              studentId: studentId,
              lessonId: 'lesson_1',
              completed: true,
              completedAt: DateTime(2024, 1, 1),
            ),
          ]);
        });
        return buildBloc();
      },
      seed: () => LessonsListLoaded(
        lessons: testLessons,
        progressMap: const {},
      ),
      act: (bloc) async {
        // Simulate initial load (sets stored IDs)
        bloc.add(const LessonsLoadRequested(
          curriculumId: curriculumId,
          studentId: studentId,
        ));
        await Future<void>.delayed(const Duration(milliseconds: 50));
        // Simulate refresh (uses stored IDs)
        bloc.add(const LessonsRefreshRequested());
      },
      expect: () => [
        const LessonsListLoading(),
        // After initial load: no progress
        LessonsListLoaded(
          lessons: testLessons,
          progressMap: const {},
        ),
        // After refresh: lesson_1 completed
        const LessonsListLoading(),
        LessonsListLoaded(
          lessons: testLessons,
          progressMap: const {'lesson_1': true},
        ),
      ],
      verify: (_) {
        verify(() => mockGetLessons(curriculumId)).called(2);
        verify(() => mockGetProgress(studentId)).called(2);
      },
    );

    blocTest<LessonsListBloc, LessonsListState>(
      'progressMap includes all completed lessons from fresh progress data',
      build: () {
        when(() => mockGetLessons(curriculumId))
            .thenAnswer((_) async => Right(testLessons));
        when(() => mockGetProgress(studentId)).thenAnswer(
          (_) async => Right([
            LessonProgress(
              id: 'prog_1',
              studentId: studentId,
              lessonId: 'lesson_1',
              completed: true,
              completedAt: DateTime(2024, 1, 1),
            ),
            LessonProgress(
              id: 'prog_2',
              studentId: studentId,
              lessonId: 'lesson_2',
              completed: false,
            ),
          ]),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LessonsLoadRequested(
        curriculumId: curriculumId,
        studentId: studentId,
      )),
      expect: () => [
        const LessonsListLoading(),
        LessonsListLoaded(
          lessons: testLessons,
          progressMap: const {
            'lesson_1': true,
            'lesson_2': false,
          },
        ),
      ],
    );
  });
}
