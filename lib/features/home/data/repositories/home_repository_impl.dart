import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/error/error_utils.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/features/home/data/datasources/home_remote_datasource.dart';
import 'package:smart_learn/features/home/domain/entities/curriculum_entity.dart';
import 'package:smart_learn/features/home/domain/entities/dictation_entity.dart';
import 'package:smart_learn/features/home/domain/entities/pictogram_entity.dart';
import 'package:smart_learn/features/home/domain/entities/proverb_entity.dart';
import 'package:smart_learn/features/home/domain/entities/subject_entity.dart';
import 'package:smart_learn/features/home/domain/entities/nnc_question_entity.dart';
import 'package:smart_learn/features/home/domain/entities/vtv_question_entity.dart';
import 'package:smart_learn/features/home/domain/repositories/home_repository.dart';

@LazySingleton(as: HomeRepository)
class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDatasource remoteDatasource;

  HomeRepositoryImpl(this.remoteDatasource);

  @override
  Future<Either<Failure, List<SubjectEntity>>> getUserSubjects() async {
    try {
      final result = await remoteDatasource.getUserSubjects();
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, List<SubjectEntity>>> getAllSubjects() async {
    try {
      final result = await remoteDatasource.getAllSubjects();
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, void>> saveUserSubjects(
    List<String> subjectIds,
  ) async {
    try {
      await remoteDatasource.saveUserSubjects({'subject_ids': subjectIds});
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, List<CurriculumEntity>>> getCurricula() async {
    try {
      final result = await remoteDatasource.getCurricula();
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, List<PictogramEntity>>> getPictogramQuestions({
    String? level,
    int? limit,
  }) async {
    try {
      final result = await remoteDatasource.getPictogramQuestions(level, limit);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, DictationEntity>> getRandomDictation({
    String? level,
    String? language,
  }) async {
    try {
      final result = await remoteDatasource.getRandomDictation(level, language);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, List<VTVQuestionEntity>>> getVTVQuestions({
    String? level,
    int? limit,
  }) async {
    try {
      final result = await remoteDatasource.getVTVQuestions(level, limit);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, List<NNCQuestionEntity>>> getNNCQuestions({
    String? level,
    int? limit,
  }) async {
    try {
      final result = await remoteDatasource.getNNCQuestions(level, limit);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, List<ProverbEntity>>> getProverbQuestions({
    String? level,
    int? limit,
  }) async {
    try {
      final result = await remoteDatasource.getProverbQuestions(level, limit);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }
}
