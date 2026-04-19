import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/features/auth/domain/entities/user_entity.dart';
import 'package:smart_learn/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_learn/features/home/domain/entities/curriculum_entity.dart';
import 'package:smart_learn/features/home/domain/entities/subject_entity.dart';
import 'package:smart_learn/features/home/domain/usecases/get_curricula.dart';
import 'package:smart_learn/features/home/domain/usecases/get_user_subjects.dart';
import 'package:smart_learn/features/home/presentation/bloc/home_bloc.dart';
import 'package:smart_learn/features/subjects/presentation/models/subject_with_count.dart';

class MockGetUserSubjectsUseCase extends Mock implements GetUserSubjectsUseCase {}

class MockGetCurriculaUseCase extends Mock implements GetCurriculaUseCase {}

class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  late MockGetUserSubjectsUseCase mockGetSubjects;
  late MockGetCurriculaUseCase mockGetCurricula;
  late MockAuthBloc mockAuthBloc;

  final testUser = UserEntity(
    id: 'user_1',
    username: 'test',
    email: 'test@test.com',
    displayName: 'Test User',
    role: 'student',
    isActive: true,
    createdAt: DateTime(2024),
  );

  final testSubjects = [
    const SubjectEntity(
      id: 'sub_1',
      name: 'Math',
      sortOrder: 1,
      curriculumCount: 5,
    ),
    const SubjectEntity(
      id: 'sub_2',
      name: 'Science',
      sortOrder: 2,
      curriculumCount: 3,
    ),
  ];

  final testCurricula = [
    const CurriculumEntity(
      id: 'cur_1',
      subjectId: 'sub_1',
      name: 'Algebra',
      isPublic: true,
      userId: 'user_1',
      lessonCount: 10,
    ),
    const CurriculumEntity(
      id: 'cur_2',
      subjectId: 'sub_1',
      name: 'Geometry',
      isPublic: true,
      userId: 'user_1',
      lessonCount: 8,
    ),
    const CurriculumEntity(
      id: 'cur_3',
      subjectId: 'sub_2',
      name: 'Physics',
      isPublic: true,
      userId: 'user_2',
      lessonCount: 5,
    ),
  ];

  setUp(() {
    mockGetSubjects = MockGetUserSubjectsUseCase();
    mockGetCurricula = MockGetCurriculaUseCase();
    mockAuthBloc = MockAuthBloc();
  });

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  group('HomeBloc', () {
    blocTest<HomeBloc, HomeState>(
      'emits [HomeLoading, HomeLoaded] when both use cases succeed',
      build: () {
        when(
          () => mockGetSubjects(any()),
        ).thenAnswer((_) async => Right(testSubjects));
        when(
          () => mockGetCurricula(any()),
        ).thenAnswer((_) async => Right(testCurricula));
        when(() => mockAuthBloc.state).thenReturn(AuthAuthenticated(testUser));
        return HomeBloc(mockGetSubjects, mockGetCurricula, mockAuthBloc);
      },
      act: (bloc) => bloc.add(const HomeLoadSubjects()),
      expect: () => [
        const HomeLoading(),
        HomeLoaded(
          subjects: [
            const SubjectWithCount(
              subject: SubjectEntity(
                id: 'sub_1',
                name: 'Math',
                sortOrder: 1,
                curriculumCount: 5,
              ),
              description: 'Môn học',
              icon: '',
              userCurriculumCount: 2,
            ),
            const SubjectWithCount(
              subject: SubjectEntity(
                id: 'sub_2',
                name: 'Science',
                sortOrder: 2,
                curriculumCount: 3,
              ),
              description: 'Môn học',
              icon: '',
              userCurriculumCount: 0,
            ),
          ],
        ),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'emits [HomeLoading, HomeLoaded] with count=0 when curricula fails',
      build: () {
        when(
          () => mockGetSubjects(any()),
        ).thenAnswer((_) async => Right(testSubjects));
        when(() => mockGetCurricula(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Network error')),
        );
        when(() => mockAuthBloc.state).thenReturn(AuthAuthenticated(testUser));
        return HomeBloc(mockGetSubjects, mockGetCurricula, mockAuthBloc);
      },
      act: (bloc) => bloc.add(const HomeLoadSubjects()),
      expect: () => [
        const HomeLoading(),
        HomeLoaded(
          subjects: [
            const SubjectWithCount(
              subject: SubjectEntity(
                id: 'sub_1',
                name: 'Math',
                sortOrder: 1,
                curriculumCount: 5,
              ),
              description: 'Môn học',
              icon: '',
              userCurriculumCount: 0,
            ),
            const SubjectWithCount(
              subject: SubjectEntity(
                id: 'sub_2',
                name: 'Science',
                sortOrder: 2,
                curriculumCount: 3,
              ),
              description: 'Môn học',
              icon: '',
              userCurriculumCount: 0,
            ),
          ],
        ),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'emits [HomeLoading, HomeError] when subjects fails',
      build: () {
        when(() => mockGetSubjects(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Server error')),
        );
        when(
          () => mockGetCurricula(any()),
        ).thenAnswer((_) async => Right(testCurricula));
        when(() => mockAuthBloc.state).thenReturn(AuthAuthenticated(testUser));
        return HomeBloc(mockGetSubjects, mockGetCurricula, mockAuthBloc);
      },
      act: (bloc) => bloc.add(const HomeLoadSubjects()),
      expect: () => [
        const HomeLoading(),
        const HomeError(message: 'Server error'),
      ],
    );
  });
}
