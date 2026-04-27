import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/error/error_utils.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/features/exam/data/datasources/exam_remote_datasource.dart';
import 'package:smart_learn/features/exam/domain/entities/exam_detail_entity.dart';
import 'package:smart_learn/features/exam/domain/entities/exam_entity.dart';
import 'package:smart_learn/features/exam/domain/repositories/exam_repository.dart';

@LazySingleton(as: ExamRepository)
class ExamRepositoryImpl implements ExamRepository {
  final ExamRemoteDatasource remoteDatasource;

  ExamRepositoryImpl(this.remoteDatasource);

  @override
  Future<Either<Failure, List<ExamEntity>>> getExams({
    String? tab,
    String? search,
  }) async {
    try {
      final result = await remoteDatasource.getExams(tab: tab, search: search);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, ExamDetailEntity>> getExamDetail(String id) async {
    try {
      final result = await remoteDatasource.getExamDetail(id);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, void>> createExam(Map<String, dynamic> body) async {
    try {
      await remoteDatasource.createExam(body);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, void>> updateExam(
    String id,
    Map<String, dynamic> body,
  ) async {
    try {
      await remoteDatasource.updateExam(id, body);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExam(String id) async {
    try {
      await remoteDatasource.deleteExam(id);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, void>> submitExamResult({
    required String examId,
    required double score,
    required int timeTaken,
  }) async {
    try {
      await remoteDatasource.submitExamResult(examId, {
        'score': score,
        'time_taken': timeTaken,
      });
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }
}
