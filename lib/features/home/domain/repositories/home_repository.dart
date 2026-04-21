import 'package:dartz/dartz.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/features/home/domain/entities/curriculum_entity.dart';
import 'package:smart_learn/features/home/domain/entities/dictation_entity.dart';
import 'package:smart_learn/features/home/domain/entities/pictogram_entity.dart';
import 'package:smart_learn/features/home/domain/entities/subject_entity.dart';
import 'package:smart_learn/features/home/domain/entities/nnc_question_entity.dart';
import 'package:smart_learn/features/home/domain/entities/learning_category_entity.dart';
import 'package:smart_learn/features/home/domain/entities/learning_question_entity.dart';
import 'package:smart_learn/features/home/domain/entities/proverb_entity.dart';
import 'package:smart_learn/features/home/domain/entities/vtv_question_entity.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<SubjectEntity>>> getUserSubjects();
  Future<Either<Failure, List<SubjectEntity>>> getAllSubjects();
  Future<Either<Failure, void>> saveUserSubjects(List<String> subjectIds);
  Future<Either<Failure, List<CurriculumEntity>>> getCurricula();
  Future<Either<Failure, List<PictogramEntity>>> getPictogramQuestions({
    String? level,
    int? limit,
  });
  Future<Either<Failure, DictationEntity>> getRandomDictation({
    String? level,
    String? language,
  });
  Future<Either<Failure, List<VTVQuestionEntity>>> getVTVQuestions({
    String? level,
    int? limit,
  });
  Future<Either<Failure, List<NNCQuestionEntity>>> getNNCQuestions({
    String? level,
    int? limit,
  });
  Future<Either<Failure, List<ProverbEntity>>> getProverbQuestions({
    String? level,
    int? limit,
  });
  Future<Either<Failure, List<LearningCategoryEntity>>> getLearningCategories();
  Future<Either<Failure, List<LearningQuestionEntity>>> getLearningQuestions(
    String categoryId,
  );
}
