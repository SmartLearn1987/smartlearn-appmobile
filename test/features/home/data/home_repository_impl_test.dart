import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/features/home/data/datasources/home_remote_datasource.dart';
import 'package:smart_learn/features/home/data/models/curriculum_model.dart';
import 'package:smart_learn/features/home/data/models/dictation_model.dart';
import 'package:smart_learn/features/home/data/models/pictogram_model.dart';
import 'package:smart_learn/features/home/data/models/subject_model.dart';
import 'package:smart_learn/features/home/data/repositories/home_repository_impl.dart';

class MockHomeRemoteDatasource extends Mock implements HomeRemoteDatasource {}

void main() {
  late MockHomeRemoteDatasource mockDatasource;
  late HomeRepositoryImpl repository;

  setUp(() {
    mockDatasource = MockHomeRemoteDatasource();
    repository = HomeRepositoryImpl(mockDatasource);
  });

  // ── Test data ──

  const tSubjects = [
    SubjectModel(
      id: 's1',
      name: 'Toán',
      sortOrder: 1,
      curriculumCount: 3,
    ),
    SubjectModel(
      id: 's2',
      name: 'Văn',
      sortOrder: 2,
      curriculumCount: 5,
    ),
  ];

  const tCurricula = [
    CurriculumModel(
      id: 'c1',
      subjectId: 's1',
      name: 'Đại số',
      isPublic: true,
      userId: 'u1',
      lessonCount: 10,
    ),
  ];

  const tPictograms = [
    PictogramModel(
      id: 'p1',
      imageUrl: 'https://example.com/img.png',
      answer: 'mèo',
      level: 'easy',
    ),
  ];

  const tDictation = DictationModel(
    id: 'd1',
    title: 'Bài chính tả 1',
    level: 'medium',
    content: 'Nội dung bài chính tả',
    language: 'vi',
  );

  DioException _dioException({String? errorMessage}) {
    return DioException(
      requestOptions: RequestOptions(path: '/test'),
      response: errorMessage != null
          ? Response(
              requestOptions: RequestOptions(path: '/test'),
              data: {'error': errorMessage},
            )
          : null,
    );
  }

  // ── getUserSubjects ──

  group('getUserSubjects', () {
    test('returns Right(List<SubjectModel>) on success', () async {
      when(() => mockDatasource.getUserSubjects())
          .thenAnswer((_) async => tSubjects);

      final result = await repository.getUserSubjects();

      expect(result, equals(const Right(tSubjects)));
      verify(() => mockDatasource.getUserSubjects()).called(1);
    });

    test('returns Left(ServerFailure) on DioException', () async {
      when(() => mockDatasource.getUserSubjects())
          .thenThrow(_dioException(errorMessage: 'Unauthorized'));

      final result = await repository.getUserSubjects();

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns Left(ServerFailure) with generic message on unknown error',
        () async {
      when(() => mockDatasource.getUserSubjects())
          .thenThrow(Exception('unexpected'));

      final result = await repository.getUserSubjects();

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Đã xảy ra lỗi không xác định');
        },
        (_) => fail('Expected Left'),
      );
    });
  });

  // ── getAllSubjects ──

  group('getAllSubjects', () {
    test('returns Right(List<SubjectModel>) on success', () async {
      when(() => mockDatasource.getAllSubjects())
          .thenAnswer((_) async => tSubjects);

      final result = await repository.getAllSubjects();

      expect(result, equals(const Right(tSubjects)));
      verify(() => mockDatasource.getAllSubjects()).called(1);
    });

    test('returns Left(ServerFailure) on DioException', () async {
      when(() => mockDatasource.getAllSubjects())
          .thenThrow(_dioException(errorMessage: 'Server error'));

      final result = await repository.getAllSubjects();

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns Left(ServerFailure) with generic message on unknown error',
        () async {
      when(() => mockDatasource.getAllSubjects())
          .thenThrow(Exception('unexpected'));

      final result = await repository.getAllSubjects();

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Đã xảy ra lỗi không xác định');
        },
        (_) => fail('Expected Left'),
      );
    });
  });

  // ── saveUserSubjects ──

  group('saveUserSubjects', () {
    test('returns Right(null) on success', () async {
      when(() => mockDatasource.saveUserSubjects(any()))
          .thenAnswer((_) async {});

      final result = await repository.saveUserSubjects(['s1', 's2']);

      expect(result, equals(const Right(null)));
      verify(
        () => mockDatasource.saveUserSubjects({'subjectIds': ['s1', 's2']}),
      ).called(1);
    });

    test('returns Left(ServerFailure) on DioException', () async {
      when(() => mockDatasource.saveUserSubjects(any()))
          .thenThrow(_dioException(errorMessage: 'Forbidden'));

      final result = await repository.saveUserSubjects(['s1']);

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns Left(ServerFailure) with generic message on unknown error',
        () async {
      when(() => mockDatasource.saveUserSubjects(any()))
          .thenThrow(Exception('unexpected'));

      final result = await repository.saveUserSubjects(['s1']);

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Đã xảy ra lỗi không xác định');
        },
        (_) => fail('Expected Left'),
      );
    });
  });

  // ── getCurricula ──

  group('getCurricula', () {
    test('returns Right(List<CurriculumModel>) on success', () async {
      when(() => mockDatasource.getCurricula())
          .thenAnswer((_) async => tCurricula);

      final result = await repository.getCurricula();

      expect(result, equals(const Right(tCurricula)));
      verify(() => mockDatasource.getCurricula()).called(1);
    });

    test('returns Left(ServerFailure) on DioException', () async {
      when(() => mockDatasource.getCurricula())
          .thenThrow(_dioException(errorMessage: 'Not found'));

      final result = await repository.getCurricula();

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns Left(ServerFailure) with generic message on unknown error',
        () async {
      when(() => mockDatasource.getCurricula())
          .thenThrow(Exception('unexpected'));

      final result = await repository.getCurricula();

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Đã xảy ra lỗi không xác định');
        },
        (_) => fail('Expected Left'),
      );
    });
  });

  // ── getPictogramQuestions ──

  group('getPictogramQuestions', () {
    test('returns Right(List<PictogramModel>) on success', () async {
      when(() => mockDatasource.getPictogramQuestions(any(), any()))
          .thenAnswer((_) async => tPictograms);

      final result = await repository.getPictogramQuestions(
        level: 'easy',
        limit: 10,
      );

      expect(result, equals(const Right(tPictograms)));
      verify(() => mockDatasource.getPictogramQuestions('easy', 10)).called(1);
    });

    test('returns Left(ServerFailure) on DioException', () async {
      when(() => mockDatasource.getPictogramQuestions(any(), any()))
          .thenThrow(_dioException(errorMessage: 'Bad request'));

      final result = await repository.getPictogramQuestions(
        level: 'hard',
        limit: 5,
      );

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns Left(ServerFailure) with generic message on unknown error',
        () async {
      when(() => mockDatasource.getPictogramQuestions(any(), any()))
          .thenThrow(Exception('unexpected'));

      final result = await repository.getPictogramQuestions();

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Đã xảy ra lỗi không xác định');
        },
        (_) => fail('Expected Left'),
      );
    });
  });

  // ── getRandomDictation ──

  group('getRandomDictation', () {
    test('returns Right(DictationModel) on success', () async {
      when(() => mockDatasource.getRandomDictation(any(), any()))
          .thenAnswer((_) async => tDictation);

      final result = await repository.getRandomDictation(
        level: 'medium',
        language: 'vi',
      );

      expect(result, equals(const Right(tDictation)));
      verify(() => mockDatasource.getRandomDictation('medium', 'vi'))
          .called(1);
    });

    test('returns Left(ServerFailure) on DioException', () async {
      when(() => mockDatasource.getRandomDictation(any(), any()))
          .thenThrow(_dioException(errorMessage: 'Not found'));

      final result = await repository.getRandomDictation(
        level: 'hard',
        language: 'en',
      );

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns Left(ServerFailure) with generic message on unknown error',
        () async {
      when(() => mockDatasource.getRandomDictation(any(), any()))
          .thenThrow(Exception('unexpected'));

      final result = await repository.getRandomDictation();

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Đã xảy ra lỗi không xác định');
        },
        (_) => fail('Expected Left'),
      );
    });
  });
}
