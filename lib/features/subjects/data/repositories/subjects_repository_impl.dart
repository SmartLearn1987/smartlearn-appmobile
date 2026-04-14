import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/error/exceptions.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/features/home/domain/entities/subject_entity.dart';
import 'package:smart_learn/features/subjects/data/datasources/subjects_remote_datasource.dart';
import 'package:smart_learn/features/subjects/domain/entities/curriculum_entity.dart';
import 'package:smart_learn/features/subjects/domain/repositories/subjects_repository.dart';
import 'package:smart_learn/features/subjects/domain/usecases/params/create_curriculum_params.dart';
import 'package:smart_learn/features/subjects/domain/usecases/params/update_curriculum_params.dart';

@LazySingleton(as: SubjectsRepository)
class SubjectsRepositoryImpl implements SubjectsRepository {
  final SubjectsRemoteDatasource remoteDatasource;

  SubjectsRepositoryImpl(this.remoteDatasource);

  @override
  Future<Either<Failure, List<SubjectEntity>>> getSubjects() async {
    try {
      final result = await remoteDatasource.getSubjects();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SubjectEntity>> getSubjectById(String id) async {
    try {
      final result = await remoteDatasource.getSubjectById(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CurriculumEntity>>> getCurriculaBySubject(
    String subjectId,
  ) async {
    try {
      final result = await remoteDatasource.getCurricula(subjectId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CurriculumEntity>> createCurriculum(
    CreateCurriculumParams params,
  ) async {
    try {
      final formData = FormData.fromMap({
        'subject_id': params.subjectId,
        'name': params.name,
        'is_public': params.isPublic,
        'lesson_count': params.lessonCount,
        'created_by': params.createdBy,
        if (params.grade != null) 'grade': params.grade,
        if (params.educationLevel != null)
          'education_level': params.educationLevel,
        if (params.publisher != null) 'publisher': params.publisher,
      });

      if (params.imageFile != null) {
        final uploadResult = await uploadImage(params.imageFile!);
        final imageUrl = uploadResult.fold(
          (failure) => null,
          (url) => url,
        );
        if (imageUrl != null) {
          formData.fields.add(MapEntry('image_url', imageUrl));
        }
      }

      final result = await remoteDatasource.createCurriculum(formData);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CurriculumEntity>> updateCurriculum(
    UpdateCurriculumParams params,
  ) async {
    try {
      final data = <String, dynamic>{
        if (params.name != null) 'name': params.name,
        if (params.grade != null) 'grade': params.grade,
        if (params.educationLevel != null)
          'education_level': params.educationLevel,
        if (params.isPublic != null) 'is_public': params.isPublic,
        if (params.publisher != null) 'publisher': params.publisher,
        if (params.lessonCount != null) 'lesson_count': params.lessonCount,
      };

      if (params.imageFile != null) {
        final uploadResult = await uploadImage(params.imageFile!);
        final imageUrl = uploadResult.fold(
          (failure) => null,
          (url) => url,
        );
        if (imageUrl != null) {
          data['image_url'] = imageUrl;
        }
      } else if (params.existingImageUrl != null) {
        data['image_url'] = params.existingImageUrl;
      }

      final result = await remoteDatasource.updateCurriculum(params.id, data);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCurriculum(String id) async {
    try {
      await remoteDatasource.deleteCurriculum(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadImage(File file) async {
    try {
      final result = await remoteDatasource.uploadImage(file);
      return Right(result.url);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
