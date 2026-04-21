import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/features/home/domain/entities/learning_question_entity.dart';
import 'package:smart_learn/features/home/domain/repositories/home_repository.dart';

@lazySingleton
class GetLearningQuestionsUseCase
    extends UseCase<List<LearningQuestionEntity>, String> {
  final HomeRepository repository;

  GetLearningQuestionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<LearningQuestionEntity>>> call(
    String categoryId,
  ) {
    return repository.getLearningQuestions(categoryId);
  }
}
