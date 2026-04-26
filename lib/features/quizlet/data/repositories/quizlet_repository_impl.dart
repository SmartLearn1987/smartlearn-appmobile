import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/error/error_utils.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/features/quizlet/data/datasources/quizlet_remote_datasource.dart';
import 'package:smart_learn/features/quizlet/domain/entities/quizlet_detail_entity.dart';
import 'package:smart_learn/features/quizlet/domain/entities/quizlet_entity.dart';
import 'package:smart_learn/features/quizlet/domain/repositories/quizlet_repository.dart';
import 'package:smart_learn/features/quizlet/domain/usecases/params/create_quizlet_params.dart';
import 'package:smart_learn/features/quizlet/domain/usecases/params/update_quizlet_params.dart';

@LazySingleton(as: QuizletRepository)
class QuizletRepositoryImpl implements QuizletRepository {
  final QuizletRemoteDatasource remoteDatasource;

  QuizletRepositoryImpl(this.remoteDatasource);

  @override
  Future<Either<Failure, List<QuizletEntity>>> getQuizlets({
    required String tab,
  }) async {
    try {
      final result = await remoteDatasource.getQuizlets(tab);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, QuizletDetailEntity>> getQuizletDetail(
    String id,
  ) async {
    try {
      final result = await remoteDatasource.getQuizletDetail(id);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, void>> createQuizlet(
    CreateQuizletParams params,
  ) async {
    try {
      await remoteDatasource.createQuizlet(params.toJson());
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, void>> updateQuizlet(
    UpdateQuizletParams params,
  ) async {
    try {
      await remoteDatasource.updateQuizlet(params.id, params.toJson());
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteQuizlet(String id) async {
    try {
      await remoteDatasource.deleteQuizlet(id);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }
}
