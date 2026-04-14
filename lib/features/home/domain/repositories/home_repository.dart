import 'package:dartz/dartz.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/features/home/domain/entities/curriculum_entity.dart';
import 'package:smart_learn/features/home/domain/entities/dictation_entity.dart';
import 'package:smart_learn/features/home/domain/entities/pictogram_entity.dart';
import 'package:smart_learn/features/home/domain/entities/subject_entity.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<SubjectEntity>>> getSubjects();
  Future<Either<Failure, List<CurriculumEntity>>> getCurricula();
  Future<Either<Failure, List<PictogramEntity>>> getPictogramQuestions({
    String? level,
    int? limit,
  });
  Future<Either<Failure, DictationEntity>> getRandomDictation({
    String? level,
    String? language,
  });
}
