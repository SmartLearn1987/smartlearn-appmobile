import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/features/quizlet/data/datasources/quizlet_remote_datasource.dart';
import 'package:smart_learn/features/quizlet/data/repositories/quizlet_repository_impl.dart';
import 'package:smart_learn/features/quizlet/domain/usecases/params/create_quizlet_params.dart';
import 'package:smart_learn/features/quizlet/domain/usecases/params/update_quizlet_params.dart';

class MockQuizletRemoteDatasource extends Mock
    implements QuizletRemoteDatasource {}

void main() {
  late MockQuizletRemoteDatasource mockDatasource;
  late QuizletRepositoryImpl repository;

  setUp(() {
    mockDatasource = MockQuizletRemoteDatasource();
    repository = QuizletRepositoryImpl(mockDatasource);
  });

  const tCreateParams = CreateQuizletParams(
    title: 'English Vocabulary',
    description: 'Basic words',
    subjectId: 'subject-1',
    grade: '7',
    educationLevel: 'Trung học cơ sở',
    isPublic: true,
    createdBy: 'user-1',
    terms: [
      TermParams(term: 'Hello', definition: 'Xin chào'),
    ],
  );

  const tUpdateParams = UpdateQuizletParams(
    id: 'quizlet-1',
    title: 'English Vocabulary Updated',
    description: 'Updated description',
    subjectId: 'subject-1',
    grade: '7',
    educationLevel: 'Trung học cơ sở',
    isPublic: false,
    terms: [
      TermParams(term: 'Goodbye', definition: 'Tạm biệt'),
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

  group('createQuizlet', () {
    test('success returns Right(null)', () async {
      when(() => mockDatasource.createQuizlet(any()))
          .thenAnswer((_) async => Future<void>.value());

      final result = await repository.createQuizlet(tCreateParams);

      expect(result, const Right(null));
      verify(() => mockDatasource.createQuizlet(tCreateParams.toJson()))
          .called(1);
    });

    test('DioException returns Left(ServerFailure)', () async {
      when(() => mockDatasource.createQuizlet(any()))
          .thenThrow(dioException(errorMessage: 'Bad request'));

      final result = await repository.createQuizlet(tCreateParams);

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('updateQuizlet', () {
    test('success returns Right(null)', () async {
      when(() => mockDatasource.updateQuizlet(any(), any()))
          .thenAnswer((_) async => Future<void>.value());

      final result = await repository.updateQuizlet(tUpdateParams);

      expect(result, const Right(null));
      verify(
        () => mockDatasource.updateQuizlet(
          tUpdateParams.id,
          tUpdateParams.toJson(),
        ),
      ).called(1);
    });

    test('DioException returns Left(ServerFailure)', () async {
      when(() => mockDatasource.updateQuizlet(any(), any()))
          .thenThrow(dioException(errorMessage: 'Not found'));

      final result = await repository.updateQuizlet(tUpdateParams);

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('deleteQuizlet', () {
    test('success returns Right(null)', () async {
      when(() => mockDatasource.deleteQuizlet(any()))
          .thenAnswer((_) async => Future<void>.value());

      final result = await repository.deleteQuizlet('quizlet-1');

      expect(result, const Right(null));
      verify(() => mockDatasource.deleteQuizlet('quizlet-1')).called(1);
    });

    test('DioException returns Left(ServerFailure)', () async {
      when(() => mockDatasource.deleteQuizlet(any()))
          .thenThrow(dioException(errorMessage: 'Unauthorized'));

      final result = await repository.deleteQuizlet('quizlet-1');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });
}
