import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:smart_learn/core/error/failures.dart';
import 'package:smart_learn/core/usecase/usecase.dart';
import 'package:smart_learn/features/quizlet/domain/repositories/quizlet_repository.dart';

@lazySingleton
class DeleteQuizletUseCase extends UseCase<void, String> {
  final QuizletRepository repository;

  DeleteQuizletUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) =>
      repository.deleteQuizlet(params);
}
