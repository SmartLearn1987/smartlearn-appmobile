import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/error/error_utils.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/features/lessons/data/datasources/lessons_remote_datasource.dart';
import 'package:smart_learn/features/lessons/domain/entities/lesson_entity.dart';
import 'package:smart_learn/features/lessons/domain/entities/lesson_image.dart';
import 'package:smart_learn/features/lessons/domain/entities/lesson_progress.dart';
import 'package:smart_learn/features/lessons/domain/repositories/lessons_repository.dart';

@LazySingleton(as: LessonsRepository)
class LessonsRepositoryImpl implements LessonsRepository {
  final LessonsRemoteDatasource remoteDatasource;

  LessonsRepositoryImpl(this.remoteDatasource);

  @override
  Future<Either<Failure, List<LessonEntity>>> getLessons(
    String curriculumId,
  ) async {
    try {
      final result = await remoteDatasource.getLessons(curriculumId);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, LessonEntity>> getLessonById(String id) async {
    try {
      final result = await remoteDatasource.getLessonById(id);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, LessonEntity>> createLesson(
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await remoteDatasource.createLesson(data);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, LessonEntity>> updateLesson(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await remoteDatasource.updateLesson(id, data);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteLesson(String id) async {
    try {
      await remoteDatasource.deleteLesson(id);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, void>> updateQuizFlashcards(
    String lessonId,
    Map<String, dynamic> data,
  ) async {
    try {
      await remoteDatasource.updateQuizFlashcards(lessonId, data);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, List<LessonImage>>> getLessonImages(
    String lessonId,
  ) async {
    try {
      final result = await remoteDatasource.getLessonImages(lessonId);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, List<LessonImage>>> uploadImages(
    String lessonId,
    List<File> images,
  ) async {
    try {
      final result = await remoteDatasource.uploadImages(lessonId, images);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteImage(
    String lessonId,
    String imageId,
  ) async {
    try {
      await remoteDatasource.deleteImage(lessonId, imageId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, List<LessonProgress>>> getProgress(
    String studentId,
  ) async {
    try {
      final result = await remoteDatasource.getProgress(studentId);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, LessonProgress>> updateProgress(
    String lessonId,
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await remoteDatasource.updateProgress(lessonId, data);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(message: extractDioErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(message: 'Đã xảy ra lỗi không xác định'));
    }
  }
}
