import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/features/home/domain/entities/subject_entity.dart';
import 'package:smart_learn/features/subjects/domain/entities/curriculum_entity.dart';
import 'package:smart_learn/features/subjects/domain/usecases/params/create_curriculum_params.dart';
import 'package:smart_learn/features/subjects/domain/usecases/params/update_curriculum_params.dart';

abstract class SubjectsRepository {
  Future<Either<Failure, List<SubjectEntity>>> getSubjects();
  Future<Either<Failure, SubjectEntity>> getSubjectById(String id);
  Future<Either<Failure, List<CurriculumEntity>>> getCurriculaBySubject(
    String subjectId,
  );
  Future<Either<Failure, CurriculumEntity>> createCurriculum(
    CreateCurriculumParams params,
  );
  Future<Either<Failure, CurriculumEntity>> updateCurriculum(
    UpdateCurriculumParams params,
  );
  Future<Either<Failure, void>> deleteCurriculum(String id);
  Future<Either<Failure, String>> uploadImage(File file);
}
