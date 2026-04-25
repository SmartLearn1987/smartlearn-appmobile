import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/features/quizlet/data/datasources/quizlet_remote_datasource.dart';
import 'package:smart_learn/features/quizlet/data/models/quizlet_detail_model.dart';
import 'package:smart_learn/features/quizlet/data/models/quizlet_model.dart';
import 'package:smart_learn/features/quizlet/data/models/quizlet_term_model.dart';
import 'package:smart_learn/features/quizlet/data/repositories/quizlet_repository_impl.dart';

class MockQuizletRemoteDatasource extends Mock
    implements QuizletRemoteDatasource {}

void main() {
  late MockQuizletRemoteDatasource mockDatasource;
  late QuizletRepositoryImpl repository;

  setUp(() {
    mockDatasource = MockQuizletRemoteDatasource();
    repository = QuizletRepositoryImpl(mockDatasource);
  });

  // ── Test data ──

  const tQuizlets = [
    QuizletModel(
      id: 'q1',
      title: 'English Vocabulary',
      subjectName: 'English',
      educationLevel: 'Trung học cơ sở',
      isPublic: true,
      userId: 'u1',
      termCount: 25,
      authorName: 'Nguyen Van A',
      createdAt: '2024-01-15T10:30:00Z',
    ),
    QuizletModel(
      id: 'q2',
      title: 'Math Formulas',
      subjectName: 'Math',
      educationLevel: 'Tiểu học',
      isPublic: false,
      userId: 'u2',
      termCount: 10,
      authorName: 'Tran Thi B',
      createdAt: '2024-02-20T08:00:00Z',
    ),
  ];

  const tQuizletDetail = QuizletDetailModel(
    id: 'q1',
    title: 'English Vocabulary',
    description: 'Basic English words',
    subjectName: 'English',
    terms: [
      QuizletTermModel(
        id: 't1',
        term: 'Hello',
        definition: 'Xin chào',
        imageUrl: null,
        sortOrder: 1,
      ),
      QuizletTermModel(
        id: 't2',
        term: 'Goodbye',
        definition: 'Tạm biệt',
        imageUrl: null,
        sortOrder: 2,
      ),
    ],
  );

  DioException dioException({String? errorMessage}) {
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

  // ── getQuizlets ──

  group('getQuizlets', () {
    test('returns Right(List<QuizletModel>) on success', () async {
      when(() => mockDatasource.getQuizlets())
          .thenAnswer((_) async => tQuizlets);

      final result = await repository.getQuizlets();

      expect(result, equals(const Right(tQuizlets)));
      verify(() => mockDatasource.getQuizlets()).called(1);
    });

    test('returns Left(ServerFailure) on DioException', () async {
      when(() => mockDatasource.getQuizlets())
          .thenThrow(dioException(errorMessage: 'Unauthorized'));

      final result = await repository.getQuizlets();

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns Left(ServerFailure) with generic message on unknown error',
        () async {
      when(() => mockDatasource.getQuizlets())
          .thenThrow(Exception('unexpected'));

      final result = await repository.getQuizlets();

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

  // ── getQuizletDetail ──

  group('getQuizletDetail', () {
    test('returns Right(QuizletDetailModel) on success', () async {
      when(() => mockDatasource.getQuizletDetail(any()))
          .thenAnswer((_) async => tQuizletDetail);

      final result = await repository.getQuizletDetail('q1');

      expect(result, equals(const Right(tQuizletDetail)));
      verify(() => mockDatasource.getQuizletDetail('q1')).called(1);
    });

    test('returns Left(ServerFailure) on DioException', () async {
      when(() => mockDatasource.getQuizletDetail(any()))
          .thenThrow(dioException(errorMessage: 'Not found'));

      final result = await repository.getQuizletDetail('q1');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('returns Left(ServerFailure) with generic message on unknown error',
        () async {
      when(() => mockDatasource.getQuizletDetail(any()))
          .thenThrow(Exception('unexpected'));

      final result = await repository.getQuizletDetail('q1');

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
