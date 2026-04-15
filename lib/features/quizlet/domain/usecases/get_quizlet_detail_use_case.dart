import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/features/quizlet/domain/entities/quizlet_detail_entity.dart';
import 'package:smart_learn/features/quizlet/domain/repositories/quizlet_repository.dart';

@lazySingleton
class GetQuizletDetailUseCase extends UseCase<QuizletDetailEntity, String> {
  final QuizletRepository repository;

  GetQuizletDetailUseCase(this.repository);

  @override
  Future<Either<Failure, QuizletDetailEntity>> call(String params) =>
      repository.getQuizletDetail(params);
}
