import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/features/quizlet/domain/entities/quizlet_entity.dart';
import 'package:smart_learn/features/quizlet/domain/repositories/quizlet_repository.dart';

@lazySingleton
class GetQuizletsUseCase extends UseCase<List<QuizletEntity>, String> {
  final QuizletRepository repository;

  GetQuizletsUseCase(this.repository);

  @override
  Future<Either<Failure, List<QuizletEntity>>> call(String params) =>
      repository.getQuizlets(tab: params);
}
