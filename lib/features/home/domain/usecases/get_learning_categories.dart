import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/features/home/domain/entities/learning_category_entity.dart';
import 'package:smart_learn/features/home/domain/repositories/home_repository.dart';

@lazySingleton
class GetLearningCategoriesUseCase
    extends UseCase<List<LearningCategoryEntity>, NoParams> {
  final HomeRepository repository;

  GetLearningCategoriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<LearningCategoryEntity>>> call(
    NoParams params,
  ) {
    return repository.getLearningCategories();
  }
}
